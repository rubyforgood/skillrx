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
class TrainingResource < ApplicationRecord
  belongs_to :topic
  has_one :language, through: :topic
  has_one_attached :document

  validates :state, presence: true

  validates_with DocumentValidator
  validates_with ResourceLanguageValidator
end
