class DataImport
  require "csv"

  def self.source
    ENV.fetch("DATA_IMPORT_SOURCE", "local")
  end

  # There are dependencies here.
  # Regions must be imported before providers
  def self.reset
    self.destroy_all_data
    self.import_all
  end

  # Imports all data except for training documents.
  def self.quick_reset
    self.destroy_all_data
    self.import_regions
    self.import_providers
    self.import_languages
    self.import_topics
    self.import_tags
    self.import_topic_tags
    self.restore_default_users
  end

  def self.purge_reports
    ImportReport.destroy_all
    ImportError.destroy_all
  end

  # This method will destroy all data in the database.
  # Use with caution!

  def self.destroy_all_data
    TagCognate.destroy_all
    ActsAsTaggableOn::Tagging.destroy_all
    ActsAsTaggableOn::Tag.destroy_all
    Topic.destroy_all
    Provider.destroy_all
    Language.destroy_all
    Region.destroy_all
    User.destroy_all
  end

  def self.import_all
    import_regions
    import_providers
    import_languages
    import_topics
    import_tags
    import_topic_tags
    import_training_documents
    restore_default_users
  end

  def self.file_path(file_name)
    Rails.root.join("import_files", file_name)
  end

  def self.import_regions
    data = get_data_file("regions.csv")

    data.each do |row|
      region = Region.find_or_initialize_by(name: row["Region"])
      region.save! if region.new_record?

      puts "#{region.name} #{region.new_record? ? "created" : "already exists"}"
    end
  end

  def self.import_providers
    data =  get_data_file("providers.csv")

    data.each do |row|
      # First, create the new provider
      provider = Provider.find_or_initialize_by(id: row["Provider_ID"])
      new_record = provider.new_record?
      if new_record
        provider.assign_attributes(
          name: row["Provider_Name"],
          provider_type: row["Provider_Type"],
          )
        provider.save!
      end
      puts "#{provider.name} #{new_record ? "created" : "already exists"}"

      # associate the provider with the region
      region_name = row["region_name"]
      region = Region.find_by(name: region_name)

      puts "Region #{region_name} not found" unless region
      provider.regions << region unless region.blank? || provider.regions.include?(region)

      # Then, create the user that will be associated with the provider
      puts "Creating user for #{provider.name}"
      email = "#{row['Provider_Name'].parameterize}@test.test"
      user = User.find_by(email: email)
      user = User.create(email: email, password_digest: BCrypt::Password.create(row["Provider_Password"])) if user.blank?

      # Then, associate the user with the provider
      provider.users << user unless provider.users.include?(user)
    end
  end

  def self.import_languages
    [
      { name: "english" },
      { name: "spanish" },
    ].each do |language|
      language = Language.find_or_create_by!(language)
      puts "#{language.name} #{language.new_record? ? "created" : "already exists"}"
    end
  end

  def self.import_topics
    data = get_data_file("topics.csv")

    data.each do |row|
      next if row["Created_Year"].to_i < 2020 || row["Topic_ID"].to_i < 6110
      # FIXME we need to search for LIKE name since the Topic_Language is 2 letter abbreviated
      language = Language.where("name like ?", "#{row["Topic_Language"]}%").first
      puts "Language #{row["Topic_Language"]} not found" unless language
      provider = Provider.find_by(id: row["Provider_ID"])
      created_year = [ row["Created_Year"].to_i, 2016 ].max
      created_month = [ row["Created_Month"].split("_").first.to_i, 1 ].max

      topic = Topic.find_or_initialize_by(id: row["Topic_ID"])
      topic.assign_attributes(
        id: row["Topic_ID"],
        title: row["Topic_Original_Title"],
        language: language,
        provider: provider,
        description: row["Topic_Desc"],
        published_at: DateTime.new(created_year, created_month, 1),
        # uid: uid,
        state: row["Topic_Archived"] == "True" ? "archived" : "active",
        )
      puts "#{topic.title} #{topic.new_record? ? "created" : "already exists"}"
      topic.save!
    end
    reset_topic_id_starting_value
  end

  def self.reset_topic_id_starting_value
    max_id = Topic.maximum(:id) || 0
    new_start_value = max_id + 1
      ActiveRecord::Base.connection.execute("SELECT setval('topics_id_seq', #{new_start_value}, ?)", false)
    puts "Reset topics ID starting value to #{new_start_value}"
  end

  def self.import_tags
    data = get_data_file("tags.csv")

    data.each do |row|
      tag_id = row["Tag_ID"].to_i
      tag_name = row["Tag_Name"]&.strip&.downcase

      begin
        Tag.find_or_create_by!(id: tag_id, name: tag_name)
      rescue ActiveRecord::RecordInvalid
        puts "Tag #{tag_name} is invalid"
      end
    end
    puts "Tags import completed"
  end

  def self.import_topic_tags
    tags_data = get_data_file("tags.csv", no_headers: true)
    join_data = get_data_file("topic_tags.csv", no_headers: true)

    # It returns a hash where the key is the Topic_ID and the value is an array of Tag_ID
    grouped_data = join_data
                     .drop(1)
                     .group_by { |row| row.first.to_i }
                     .transform_values { |values| values.map(&:last).map(&:to_i) }

    # It returns the corresponding Tag record from the database based on the name
    find_by_name = ->(tags_data, tag_id) do
      _id, name, _language = tags_data.find { |row| row.first.to_i == tag_id }
      Tag.find_by(name: name)
    end

    # Iterate over the dictionary of lists
    grouped_data.each do |topic_id, tag_ids|
      topic = Topic.find_by(id: topic_id)
      next if topic.nil?

      # Build a string with the tag names
      tag_names_str = tag_ids.filter_map do |tag_id|
        Tag.find_by(id: tag_id)&.name&.strip || find_by_name.(tags_data, tag_id)&.name&.strip
      end.join(",")

      # Set the topic tags in the pertinent context (language comes from the topic's language)
      topic.set_tag_list_on(topic.language.code.to_sym, tag_names_str)
      topic.save!

      puts "#{topic.title} - #{topic.id} / Tags: #{topic.current_tags_list}"
    end
    puts "Topic tags import completed"
  end

  def self.restore_default_users
    return if User.find_by_email("admin@email.com")

    admin = User.find_by(email: "admin@mail.com")
    if admin.nil?
      admin = User.create!(email: "admin@mail.com", password: "test123", is_admin: true)
    end
    Provider.all.each do |provider|
      provider.users << admin unless provider.users.include?(admin)
    end

    me = User.find_by(email: "me@mail.com")
    if me.nil?
      me = User.create!(email: "me@mail.com", password: "test123")
    end

    Provider.first.users << me unless Provider.first.users.include?(me)
  end

  def self.import_training_documents
    topics_data = get_data_file("topics.csv")
    old_topic_ids = Set.new
    topics_data.each do |row|
      old_topic_ids << row["Topic_ID"] if row["Created_Year"].to_i < 2020
    end

    report = ImportReport.create!(
      import_type: "training_documents",
      started_at: Time.current,
      status: "pending"
    )

    begin
      csv_data = get_data_file("cme_files.csv")
      import_stats = initialize_import_stats

      valid_csv_rows = filter_rows_with_existing_topics(csv_data, import_stats, old_topic_ids)
      azure_files = fetch_azure_files
      importable_rows = match_csv_with_azure_files(valid_csv_rows, azure_files)
      unmatched_files = collect_unmatched_files(valid_csv_rows, azure_files, importable_rows, report)

      report.update!(
        summary_stats: build_summary_stats(import_stats, csv_data, azure_files),
        unmatched_files: unmatched_files,
        status: "planned"
      )

      process_document_attachments(importable_rows, import_stats, report)

      report.update!(
        completed_at: Time.current,
        status: "completed",
        summary_stats: build_summary_stats(import_stats, csv_data, azure_files),
        unmatched_files: unmatched_files
      )

      log_final_results(import_stats)
    rescue => e
      report.update!(status: "failed", error_details: [ { error: e.message } ])
      raise
    end
  end

  private

  def self.initialize_import_stats
    {
      topics_without_csv: [],
      successful_attachments: [],
      failed_attachments: [],
      error_files: [],
    }
  end

  def self.filter_rows_with_existing_topics(csv_data, stats, old_topic_ids)
    csv_data.filter_map do |row|
      topic_id = row["Topic_ID"].to_i
      next if old_topic_ids.include?("#{topic_id}")

      if Topic.find_by(id: topic_id)
        row
      else
        stats[:topics_without_csv] << topic_id
        nil
      end
    end
  end

  def self.match_csv_with_azure_files(csv_rows, azure_files)
    azure_files.filter_map do |file|
      csv_rows.find { |row| row["File_Name"] == file[:name] }
    end
  end

  def self.process_document_attachments(rows, stats, report)
    rows.each do |row|
      topic = Topic.find_by(id: row["Topic_ID"])
      next unless topic

      attach_document_to_topic(topic, row, stats, report)
    end
  end

  def self.attach_document_to_topic(topic, row, stats, report)
    file_path = get_file_path(topic.state, topic.language.name)
    filename = row["File_Name"]

    puts "Requesting: #{file_path}/#{filename}"

    begin
      file_content = download_azure_file(file_path, filename)

      topic.documents.attach(
        io: StringIO.new(file_content),
        filename: filename,
        content_type: detect_content_type(row["File_Type"])
      )

      if topic.save!
        stats[:successful_attachments] << [ row, topic ]
      else
        stats[:failed_attachments] << [ row, topic ]
      end

    rescue AzureFileShares::Errors::ApiError, URI::InvalidURIError => e
      handle_attachment_error(topic, filename, e, stats, report)
    end
  end

  def self.get_data_file(file_name, no_headers: false)
    # Determine the source of the data file
    # It can be either "local" or "azure"
    # The source is determined by the DATA_IMPORT_SOURCE environment variable
    source = self.source

    if source == "local"
      CSV.read(file_path(file_name), headers: true)
    elsif source == "azure"
      get_data_file_from_azure(file_name, no_headers: no_headers)
    else
      raise ArgumentError, "Invalid source: #{source}"
    end
  end

  def self.get_data_file_from_azure(file_name, no_headers: false)
    # Assuming the file is stored in a specific path in Azure
    # Adjust the file_path as needed based on your Azure structure
    # For example, if files are stored in a specific directory:
    file_path = "/import_files"
    begin
      file_content = download_azure_file(file_path, file_name)
      if no_headers
        CSV.parse(file_content, headers: false, encoding: "UTF-8")
      else
        CSV.parse(file_content, headers: true, encoding: "UTF-8")
      end
    rescue AzureFileShares::Errors::ApiError => e
      puts "Error downloading file from Azure: #{e.message}"
      raise e
    end
  end

  def self.download_azure_file(file_path, filename)
    encoded_filename = URI.encode_www_form_component(filename)
    AzureFileShares.client.files.download_file(
      ENV["AZURE_STORAGE_SHARE_NAME"],
      file_path,
      encoded_filename
    )
  end

  def self.handle_attachment_error(topic, filename, error, stats, report)
    ImportError.create!(
      import_report_id: report.id,
      topic_id: topic.id,
      file_name: filename,
      error_type: error.class.to_s,
      error_message: error.message
    )

    stats[:error_files] << {
      topic: topic,
      file: filename,
      error: error.message,
    }
    puts "Error with file: #{filename} for topic #{topic.title} - #{error.message}"
  end

  def self.collect_unmatched_files(csv_data, azure_files, importable_rows, report)
    csv_file_names = csv_data.map { |row| row["File_Name"] }
    azure_file_names = azure_files.map { |file| file[:name] }
    matched_file_names = importable_rows.map { |row| row["File_Name"] }

    r = {
      csv_without_azure_files: csv_file_names - azure_file_names,
      azure_files_without_csv: azure_file_names - csv_file_names,
      total_unmatched: (csv_file_names + azure_file_names - matched_file_names).uniq,
    }

    r[:csv_without_azure_files].each do |csv_row_name|
      ImportError.create!(
        import_report_id: report.id,
        file_name: csv_row_name,
        error_type: "CSV::Row::File not found in Azure",
        error_message: "CSV Row File not found in Azure",
        topic_id: csv_row_name.split("_").first
      )
    end

    r[:azure_files_without_csv].each do |azure_file_name|
      ImportError.create!(
        import_report_id: report.id,
        file_name: azure_file_name,
        error_type: "Azure::File not found in CSV",
        error_message: "Azure::File not found in CSV",
        topic_id: azure_file_name.split("_").first
      )
    end

    r
  end

  def self.build_summary_stats(import_stats, csv_data, azure_files)
    {
      total_csv_files: csv_data.size,
      total_azure_files: azure_files.size,
      successful_attachments: import_stats[:successful_attachments].size,
      failed_attachments: import_stats[:failed_attachments].size,
      topics_without_csv: import_stats[:topics_without_csv].size,
      error_files: import_stats[:error_files].size,
    }
  end

  def self.log_final_results(stats)
    puts "Topics not found: #{stats[:topics_without_csv].size}"
    puts "Successful attachments: #{stats[:successful_attachments].size}"
    puts "Failed attachments: #{stats[:failed_attachments].size}"
    puts "Files with errors: #{stats[:error_files].size}"
  end

  private

  def self.get_file_path(state, language)
    case [ state, language ]
    in [ "active", "english" ]
      "CMES-Pi/assets/Content"
    in [ "archived", "english" ]
      "CMES-Pi_Archive"
    in [ "active", "spanish" ]
      "SP_CMES-Pi/assets/Content"
    in [ "archived", "spanish" ]
      "SP_CMES-Pi_Archive"
    end
  end

  def self.fetch_azure_files
    client = AzureFileShares.client
    azure_active_en = client.files.list(ENV["AZURE_STORAGE_SHARE_NAME"], self.get_file_path("active", "english"))
    azure_active_es = client.files.list(ENV["AZURE_STORAGE_SHARE_NAME"], self.get_file_path("active", "spanish"))
    azure_archived_en = client.files.list(ENV["AZURE_STORAGE_SHARE_NAME"], self.get_file_path("archived", "english"))
    azure_archived_es = client.files.list(ENV["AZURE_STORAGE_SHARE_NAME"], self.get_file_path("archived", "spanish"))

    [
      azure_active_en[:files],
      azure_active_es[:files],
      azure_archived_en[:files],
      azure_archived_es[:files],
    ].flatten
  end

  def self.detect_content_type(filename)
    case File.extname(filename).downcase
    when ".mp3"
      "audio/mpeg"
    when ".pdf"
      "application/pdf"
    when ".jpg", ".jpeg"
      "image/jpeg"
    when ".png"
      "image/png"
    else
      "application/octet-stream"
    end
  end
end
