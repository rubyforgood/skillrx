# == Schema Information
#
# Table name: topics
#
#  id           :bigint           not null, primary key
#  description  :text
#  published_at :datetime         not null
#  state        :integer          default("active"), not null
#  title        :string           not null
#  uid          :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  language_id  :bigint
#  old_id       :integer
#  provider_id  :bigint
#
# Indexes
#
#  index_topics_on_language_id   (language_id)
#  index_topics_on_old_id        (old_id) UNIQUE
#  index_topics_on_provider_id   (provider_id)
#  index_topics_on_published_at  (published_at)
#
class Topic < ApplicationRecord
  include Searcheable
  include LocalizedTaggable

  STATES = %i[active archived].freeze
  CONTENT_TYPES = %w[image/jpeg image/png image/svg+xml image/webp image/avif image/gif video/mp4 application/pdf].freeze

  belongs_to :language
  belongs_to :provider
  has_many_attached :documents

  validates :title, :language_id, :provider_id, presence: true
  validates :documents, content_type: CONTENT_TYPES, size: { less_than: 10.megabytes }

  enum :state, STATES.map.with_index.to_h

  scope :active, -> { where(state: :active) }
end
