# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Destroying current records..."

Topic.destroy_all
Provider.destroy_all
Language.destroy_all
User.destroy_all
Tag.destroy_all

puts "Creating languages..."

[
  { name: "english" },
  { name: "spanish" },
].each do |language|
  Language.find_or_create_by!(language)
end

puts "Languages created!"

puts "Creating providers..."

[
  { name: "Provided by the government", provider_type: "government" },
].each do |provider|
  Provider.find_or_create_by!(provider)
end

puts "Providers created!"

puts "Creating topics..."

[
  {
    title: "Introduction to English",
    description: "Learn the basics of English",
    language_id: Language.find_by(name: "english").id,
    provider_id: Provider.find_by(name: "Provided by the government").id,
    uid: "d290f1ee-6c54-4b01-90e6-d701748f0851",
    published_at: Time.now - 1.day,
    state: :active,
  },
  {
    title: "Introduction to Spanish",
    description: "Learn the basics of Spanish",
    language_id: Language.find_by(name: "spanish").id,
    provider_id: Provider.find_by(name: "Provided by the government").id,
    uid: "d290f1ee-6c54-4b01-90e6-d701748f0852",
    published_at: Time.now - 1.day,
    state: :archived,
  },
].each do |topic|
  Topic.find_or_create_by!(topic)
end

puts "Topics created!"

puts "Tagging topics.."
Topic.all.each do |topic|
  topic.tag_list.add([ Faker::ProgrammingLanguage.name, Faker::ProgrammingLanguage.name, Faker::ProgrammingLanguage.name ])
  topic.save
end

puts "Topics tagged!"

puts "Creating tags cognates..."
Tag.first.tag_cognates.create(cognate_id:  Tag.second.id)
puts "Cognates created!"

puts "Creating users..."

users = [
  { email: "admin@mail.com", password: "test123", is_admin: true },
  { email: "me@mail.com", password: "test123" },
].map do |user_data|
  user = User.find_or_initialize_by(email: user_data[:email]).tap do |u|
    u.password = user_data[:password]
    u.is_admin = user_data[:is_admin] || false
    u.providers << Provider.first unless u.is_admin
    u.save!
  end
end

me = users.last
Provider.all.each do |provider|
  provider.users << me
end

10.times do
  user = User.find_or_initialize_by(email: Faker::Internet.email).tap do |u|
    u.password = Faker::Internet.password
    u.is_admin = false
    u.providers << Provider.first unless u.is_admin
    u.save!
  end
end

puts "Users created!"

if ENV["SEED_MODE_HEAVY_LOAD"]
  times = ENV["SEED_MODE_HEAVY_LOAD"].to_i
  times.times do
    provider = Provider.find_or_create_by!(name: Faker::Company.name, provider_type: "government")
    times.times do
      Topic.find_or_create_by!(
        title: Faker::Book.title,
        description: Faker::Lorem.paragraph,
        language_id: Language.first.id,
        provider_id: provider.id,
        uid: SecureRandom.uuid,
        published_at: Time.now - rand(1..365).days,
        state: [ :active, :archived ].sample,
      )
    end
  end
end
