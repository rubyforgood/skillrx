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

puts "Creating regions..."

[ "Northeast", "Southeast", "Midwest", "Southwest", "West" ].each do |name|
  Region.find_or_create_by!(name: name)
end

puts "Regions created!"

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
  topic.tag_list.add(3.times.map { Faker::ProgrammingLanguage.name })
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
  User.find_or_initialize_by(email: user_data[:email]).tap do |u|
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
  User.find_or_initialize_by(email: Faker::Internet.email).tap do |u|
    u.password = Faker::Internet.password
    u.is_admin = false
    u.providers << Provider.first unless u.is_admin
    u.save!
  end
end

puts "Users created!"

# Enough to see every screen with real content, not an empty state: a second provider, a page and a
# half of topics (pagination), a few documents, beacons in each sync state, and import reports.
# Idempotent: re-running finds what's there.
puts "Creating screen data..."

english = Language.find_by!(name: "english")
spanish = Language.find_by!(name: "spanish")
government = Provider.find_by!(name: "Provided by the government")
clinic = Provider.find_or_create_by!(name: "Community health clinic", provider_type: "ngo")
clinic.regions << Region.first unless clinic.regions.include?(Region.first)
government.regions << Region.second unless government.regions.include?(Region.second)
me.providers << clinic unless me.providers.include?(clinic)

[
  ["Hand hygiene in the clinic", "When and how to wash hands between patients: the five moments, handrub and handwash.", spanish],
  ["Neonatal resuscitation basics", "The first minute after birth: drying, warming, airway, and when to start ventilation.", english],
  ["Managing childhood diarrhea", "Oral rehydration, zinc, and the danger signs that need referral.", english],
  ["Malaria rapid diagnostic tests", "Running, reading and recording an RDT, and what a negative result does and doesn't mean.", english],
  ["Vacunación infantil", "El calendario de vacunación, la cadena de frío y cómo registrar cada dosis.", spanish],
  ["Safe injection practices", "One needle, one syringe, one time: preparing, giving and disposing of injections safely.", english],
  ["Recognizing pneumonia in children", "Counting breaths, chest indrawing, and when to give amoxicillin.", english],
  ["Antenatal care visits", "What to check at each of the eight recommended visits.", english],
  ["Diabetes in primary care", "Screening, foot checks, and adjusting metformin.", english],
  ["Hypertension follow-up", "Measuring blood pressure correctly and stepping up treatment.", english],
  ["Postpartum hemorrhage", "Active management of the third stage of labor and the first hour after birth.", english],
  ["Salud mental en la comunidad", "Reconocer la depresión y cómo hablar de ella con los pacientes.", spanish],
  ["Wound care and dressings", "Cleaning, closing and dressing a wound, and the signs of infection.", english],
  ["Tuberculosis treatment support", "Directly observed therapy and what to do when a dose is missed.", english],
  ["Nutrition in the first 1,000 days", "Breastfeeding, complementary foods, and growth monitoring.", english],
  ["Snakebite first aid", "What to do and what not to do before the patient reaches a facility.", english],
  ["Burns: first response", "Cooling, covering, and estimating the area burned.", english],
  ["Oxygen therapy basics", "Pulse oximetry and starting, adjusting and stopping oxygen.", english],
  ["Infection prevention for HIV", "Post-exposure prophylaxis after a needlestick.", english],
  ["Cold chain for vaccines", "Keeping vaccines between 2 and 8 °C from delivery to the patient.", english],
  ["Dengue warning signs", "When a fever needs hospital care.", spanish],
  ["Family planning counseling", "Presenting the methods so a patient can choose.", english],
  ["Eye infections in newborns", "Prevention at birth and treating conjunctivitis.", english],
  ["Assessing dehydration", "Plan A, B and C, and reassessing.", english],
  ["Pain relief after surgery", "Pain scores and stepping from paracetamol to opioids.", english],
  ["Cholera outbreak response", "Setting up an oral rehydration point.", english],
].each_with_index do |(title, description, language), i|
  provider = i.even? ? government : clinic
  provider.topics.find_or_create_by!(title: title) do |t|
    t.description = description
    t.language = language
    t.uid = SecureRandom.uuid
    t.published_at = (i * 11 + 3).days.ago
    t.state = (i % 7 == 6) ? :archived : :active
  end
end

# A few real documents, so the topic pages and beacon counts aren't all zero.
government.topics.where(state: :active).limit(3).each_with_index do |topic, i|
  next if topic.documents.attached?
  topic.documents.attach(io: StringIO.new("%PDF-1.4\n% SkillRx sample document #{i + 1}\n"), filename: "#{topic.title.parameterize}.pdf", content_type: "application/pdf")
  topic.documents.attach(io: StringIO.new("Sample audio #{i + 1}"), filename: "#{topic.title.parameterize}-audio.mp3", content_type: "audio/mpeg")
end

# Beacons in each state: synced and online, outdated, in error, never seen, and revoked.
# Content versions: the latest manifest is 4; a synced beacon reports 4, an outdated or failing one 3.
[
  ["Kisumu district hospital", english, Region.first, "synced", 5.minutes.ago, nil],
  ["Mobile clinic van 2", english, Region.second, "outdated", 3.days.ago, nil],
  ["Hospital rural San Pedro", spanish, Region.third, "error", 2.hours.ago, nil],
  ["Training center laptop", english, Region.first, nil, nil, nil],
  ["Old field tablet", english, Region.second, "synced", 40.days.ago, 10.days.ago],
].each do |name, language, region, status, seen, revoked|
  next if Beacon.exists?(name: name)
  key = Beacons::ApiKeyGenerator.new.call
  beacon = Beacon.create!(name: name, language: language, region: region, api_key_digest: key.digest, api_key_prefix: key.prefix,
                          sync_status: status, last_seen_at: seen, last_sync_at: seen, revoked_at: revoked,
                          last_sync_error: (status == "error" ? "Manifest checksum mismatch: expected 9f2c, got 4b1a" : nil))
  beacon.providers << (language == spanish ? government : [government, clinic].sample)
  beacon.update!(manifest_version: 4, reported_manifest_version: { "synced" => "4", "outdated" => "3", "error" => "3" }[status])
end

# Import reports: one completed, one with errors, one still running.
[
  ["topics_csv", "completed", 2.days.ago, { "topics_created" => 18, "topics_updated" => 4, "documents_attached" => 31 }, []],
  ["topics_csv", "failed", 6.hours.ago, { "topics_created" => 0 }, [["missing_file", "malaria-rdt-poster.pdf", "File listed in the CSV was not found in the upload"], ["invalid_language", nil, "Language 'portuguese' does not exist"]]],
  ["documents_zip", "pending", nil, nil, []],
].each do |type, status, started, stats, errors|
  next if ImportReport.exists?(import_type: type, status: status)
  report = ImportReport.create!(import_type: type, status: status, started_at: started, completed_at: (started && status != "pending" ? started + 3.minutes : nil), summary_stats: stats)
  errors.each { |kind, file, message| report.import_errors.create!(error_type: kind, file_name: file, error_message: message) }
end

puts "Screen data created!"

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
