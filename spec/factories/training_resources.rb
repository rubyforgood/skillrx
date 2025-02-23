# == Schema Information
#
# Table name: training_resources
#
#  id                 :bigint           not null, primary key
#  file_name_override :string
#  state              :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  topic_id           :bigint
#
# Indexes
#
#  index_training_resources_on_topic_id  (topic_id)
#
FactoryBot.define do
  factory :training_resource do
    sequence(:file_name_override) { |n| "file_name_override_#{n}.jpg" }
    document {  Rack::Test::UploadedFile.new("spec/support/images/logo_ruby_for_good.png", "image/png") }
    state { 1 }
    topic
  end
end
