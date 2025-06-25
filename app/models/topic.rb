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
  include Taggable

  STATES = %i[active archived].freeze
  CONTENT_TYPES = %w[image/jpeg image/png image/svg+xml image/webp image/avif image/gif video/mp4 application/pdf audio/mpeg].freeze

  belongs_to :language
  belongs_to :provider
  has_many_attached :documents

  validates :title, :language_id, :provider_id, :published_at, presence: true
  validates :documents, content_type: CONTENT_TYPES, size: { less_than: 200.megabytes }

  enum :state, STATES.map.with_index.to_h

  after_save :documents_changed_action

  scope :active, -> { where(state: :active) }

  def published_at_year
    published_at&.year
  end

  def published_at_month
    published_at&.month
  end

  class << self
    def by_year(year)
      where("extract(year from published_at) = ?", year)
    end

    def by_month(month)
      where("extract(month from published_at) = ?", month)
    end
  end

  private

  def documents_changed_action
    documents_attachments.each do |doc|
      next unless doc.previous_changes.present?

      DocumentSyncJob.perform_later(
        topic_id: id,
        document_id: doc.id,
        action: doc.previous_changes.keys.include?("blob_id") ? "update" : "create"
        # previous_changes: doc.previous_changes,
      )
    end
  end
end
