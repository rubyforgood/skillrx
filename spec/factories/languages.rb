FactoryBot.define do
  factory :language do
    name { Faker::Name.name }
    file_share_folder { Faker::File.dir }
  end
end
