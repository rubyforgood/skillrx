# == Schema Information
#
# Table name: topics
#
#  id          :bigint           not null, primary key
#  description :text             not null
#  state       :integer          default("active"), not null
#  title       :string           not null
#  uid         :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :bigint
#  provider_id :bigint
#
# Indexes
#
#  index_topics_on_language_id  (language_id)
#  index_topics_on_provider_id  (provider_id)
#
class Topic < ApplicationRecord
  include Searcheable

  belongs_to :language
  belongs_to :provider
  has_many :training_resources

  validates :title, :language_id, :provider_id, presence: true

  STATES = %i[active archived].freeze

  enum :state, STATES.map.with_index.to_h

  scope :active, -> { where(state: :active) }
end
