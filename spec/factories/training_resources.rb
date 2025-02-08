FactoryBot.define do
  factory :training_resource do
    sequence(:file_name_override) { |n| "file_name_override_#{n}.jpg" }
    document {  Rack::Test::UploadedFile.new("spec/support/images/logo_ruby_for_good.png", "image/png") }
    state { 1 }
    topic
  end
end
