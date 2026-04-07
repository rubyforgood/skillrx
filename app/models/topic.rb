# == Schema Information
#
# Table name: topics
# Database name: primary
#
#  id              :bigint           not null, primary key
#  description     :text
#  document_prefix :string
#  published_at    :datetime         not null
#  shadow_copy     :boolean          default(FALSE), not null
#  state           :integer          default("active"), not null
#  title           :string           not null
#  uid             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  language_id     :bigint
#  old_id          :integer
#  provider_id     :bigint
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
  INTERNAL_FILENAME_PREFIX = "[skillrx_internal_upload]".freeze

  default_scope { where(shadow_copy: false) }

  belongs_to :language
  belongs_to :provider
  has_many :beacon_topics, dependent: :destroy
  has_many :beacons, through: :beacon_topics
  has_many_attached :documents, dependent: :purge

  validates :title, :language_id, :provider_id, :published_at, presence: true
  validates :documents, content_type: CONTENT_TYPES, size: { less_than: 200.megabytes }

  enum :state, STATES.map.with_index.to_h

  scope :active, -> { where(state: :active) }

  class << self
    def by_year(year)
      return all if year.blank?

      where("extract(year from published_at) = ?", year.to_i)
    end

    def by_month(month)
      return all if month.blank?

      where("extract(month from published_at) = ?", month.to_i)
    end
  end

  def published_at_year
    published_at&.year
  end

  def published_at_month
    published_at&.month
  end

  def doc_prefix
    return document_prefix if document_prefix.present?

    id
  end

  # naming convention described here: https://github.com/rubyforgood/skillrx/issues/305
  # [topic.id]_[provider.provider_name_for_file.parameterize]_[topic.published_at_year]_[topic.published_at_month][document_filename.parameterize].[document_extension]
  def custom_file_name(document)
    topic_data = [
      doc_prefix,
      provider.file_name_prefix.present? ? provider.file_name_prefix.parameterize : provider.name.parameterize(separator: "_"),
      published_at_year,
      published_at_month,
    ].compact.join("_")

    document.filename.to_s.sub(INTERNAL_FILENAME_PREFIX, topic_data)
  end
end
