# == Schema Information
#
# Table name: topics
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

  default_scope { where(shadow_copy: false) }

  belongs_to :language
  belongs_to :provider
  has_many_attached :documents, dependent: :purge

  validates :title, :language_id, :provider_id, :published_at, presence: true
  validates :documents, content_type: CONTENT_TYPES, size: { less_than: 200.megabytes }

  enum :state, STATES.map.with_index.to_h

  scope :active, -> { where(state: :active) }

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

  def custom_file_name(document)
    [
      id,
      provider.file_name_prefix.present? ? provider.file_name_prefix.parameterize : provider.name.parameterize(separator: "_"),
      published_at_year,
      published_at_month,
      document.filename.base.sub("rename_", "").parameterize(separator: "_"),
    ].compact.join("_") + "." + document.filename.extension
  end

  class << self
    def by_year(year)
      where("extract(year from published_at) = ?", year)
    end

    def by_month(month)
      where("extract(month from published_at) = ?", month)
    end
  end
end
