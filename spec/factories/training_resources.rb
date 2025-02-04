FactoryBot.define do
  factory :training_resource do
    state { 1 }
    document {  Rack::Test::UploadedFile.new("spec/support/images/logo_ruby_for_good.png", "image/png") }
  end
end
