# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

[
  { name: "english", file_share_folder: "languages/english" },
  { name: "spanish", file_share_folder: "languages/spanish" },
].each do |language|
  Language.find_or_create_by!(language)
end

[
  { name: "Provided by the government", provider_type: "government" },
].each do |provider|
  Provider.find_or_create_by!(provider)
end

[
  {
    title: "Introduction to English",
    description: "Learn the basics of English",
    language_id: Language.find_by(name: "english").id,
    provider_id: Provider.find_by(name: "Provided by the government").id,
    uid: "d290f1ee-6c54-4b01-90e6-d701748f0851",
    state: :active,
  },
  {
    title: "Introduction to Spanish",
    description: "Learn the basics of Spanish",
    language_id: Language.find_by(name: "spanish").id,
    provider_id: Provider.find_by(name: "Provided by the government").id,
    uid: "d290f1ee-6c54-4b01-90e6-d701748f0852",
    state: :archived,
  },
].each do |topic|
  Topic.find_or_create_by!(topic)
end
