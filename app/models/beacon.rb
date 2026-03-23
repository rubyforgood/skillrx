# == Schema Information
#
# Table name: beacons
# Database name: primary
#
#  id                     :bigint           not null, primary key
#  api_key_digest         :string           not null
#  api_key_prefix         :string           not null
#  manifest_checksum      :string
#  manifest_data          :jsonb
#  manifest_version       :integer          default(0), not null
#  name                   :string           not null
#  previous_manifest_data :jsonb
#  revoked_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  language_id            :bigint           not null
#  region_id              :bigint           not null
#
# Indexes
#
#  index_beacons_on_api_key_digest  (api_key_digest) UNIQUE
#  index_beacons_on_language_id     (language_id)
#  index_beacons_on_region_id       (region_id)
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#  fk_rails_...  (region_id => regions.id)
#
class Beacon < ApplicationRecord
  belongs_to :language
  belongs_to :region

  has_many :beacon_providers, dependent: :destroy
  has_many :providers, through: :beacon_providers

  has_many :beacon_topics, dependent: :destroy
  has_many :topics, through: :beacon_topics

  delegate :name, to: :region, prefix: true
  delegate :name, to: :language, prefix: true

  validates :name, presence: true
  validates :api_key_digest, presence: true, uniqueness: true
  validates :api_key_prefix, presence: true

  scope :active, -> { where(revoked_at: nil) }
  scope :revoked, -> { where.not(revoked_at: nil) }

  def revoke!
    update!(revoked_at: Time.current)
  end

  def revoked?
    revoked_at.present?
  end

  # Get count of topics that match this beacon's configuration
  def document_count
    topics.count
  end

  # Get count of actual document files attached to matching topics
  def file_count
    topics.joins(:documents_attachments).count
  end

  def accessible_blobs
    ActiveStorage::Blob
      .joins(:attachments)
      .where(
        active_storage_attachments: {
          record_type: "Topic",
          name: "documents",
          record_id: topic_ids,
        }
      )
  end
end
