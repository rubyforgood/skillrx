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
    # import_languages
    # import_branches
    # import_contributors
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
      provider.save! if provider.new_record?
      puts "#{provider.name} #{provider.new_record? ? "created" : "already exists"}"

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
    language = Language.find_by(name: row["Topic_Language"][0..1].capitalize)

    data.each do |row|
      topic = Topic.find_or_initialize_by(name: row["name"], language_id: language.id)
      puts "#{contributor.name} #{contributor.new_record? ? "created" : "already exists"}"
    end
  end
end
