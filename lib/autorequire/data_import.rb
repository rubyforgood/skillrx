class DataImport
  require "csv"

  # There are dependencies here.
  # Regions must be imported before providers

  def self.destroy_all_data
    ActiveRecord::Base.descendants.each(&:delete_all)
  end

  def self.import_all
    import_regions
    import_providers
    import_languages
    # import_branches
    # import_contributors
    import_topics
  end

  def self.file_path(file_name)
    Rails.root.join("import_files", file_name)
  end

  def self.import_regions
    data = CSV.read(file_path("regions.csv"), headers: true)

    data.each do |row|
      region = Region.find_or_initialize_by(name: row["Region"])
      region.save! if region.new_record?

      puts "#{region.name} #{region.new_record? ? "created" : "already exists"}"
    end
  end

  def self.import_providers
    data = CSV.read(file_path("providers_obfuscated.csv"), headers: true)

    data.each do |row|
      # First, create the new provider
      # We need to also store the provider's old id
      provider = Provider.find_or_initialize_by(name: row["Provider_Name"], provider_type: row["Provider_Type"])
      provider.old_id = row["Provider_ID"]
      new_record = provider.new_record?
      provider.save! if new_record
      puts "#{provider.name} #{new_record ? "created" : "already exists"}"

      # associate the provider with the region
      region_name = row["region_name"]
      region = Region.find_by(name: region_name)

      puts "Region #{region_name} not found" unless region
      provider.regions << region unless region.blank? || provider.regions.include?(region)

      # Then, create the user that will be associated with the provider
      puts "Creating user for #{provider.name}"
      user = User.find_or_initialize_by(email: "#{row["Provider_Name"]}@test.test", password_digest: BCrypt::Password.create(row["Provider_Password"]))
      user.save! if user.new_record?

      # Then, associate the user with the provider
      provider.users << user unless provider.users.include?(user)
    end
  end

  def self.import_languages
    [
      { name: "english", file_share_folder: "languages/english" },
      { name: "spanish", file_share_folder: "languages/spanish" },
    ].each do |language|
      language = Language.find_or_create_by!(language)
      puts "#{language.name} #{language.new_record? ? "created" : "already exists"}"
    end
  end

  def self.import_topics
    data = CSV.read(file_path("topics_obfuscated.csv"), headers: true)

    data.each do |row|
      # FIXME we need to search for LIKE name since the Topic_Language is 2 letter abbreviated
      language = Language.where("name like ?", "#{row["Topic_Language"]}%").first
      puts "Language #{row["Topic_Language"]} not found" unless language
      provider = Provider.find_by(old_id: row["Provider_ID"])

      topic = Topic.find_or_initialize_by(old_id: row["Topic_ID"])
      topic.assign_attributes(
        title: row["Topic_Original_Title"],
        language: language,
        provider: provider,
        description: row["Topic_Desc"],
        uid: row["Topic_UID"],
        state: row["Topic_Archived"].to_i,
      )
      topic.save!
      puts "#{topic.title} #{topic.new_record? ? "created" : "already exists"}"
    end
  end
end
