# == Schema Information
#
# Table name: beacons
# Database name: primary
#
#  id             :bigint           not null, primary key
#  api_key_digest :string           not null
#  api_key_prefix :string           not null
#  name           :string           not null
#  revoked_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language_id    :bigint           not null
#  region_id      :bigint           not null
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

  validates :name, presence: true
  validates :api_key_digest, presence: true, uniqueness: true
  validates :api_key_prefix, presence: true

  scope :active, -> { where(revoked_at: nil) }
  scope :revoked, -> { where.not(revoked_at: nil) }

  def regenerate
    key_result = Beacons::ApiKeyGenerator.new.call

    update!(
      api_key_digest: key_result.digest,
      api_key_prefix: key_result.prefix,
      revoked_at: nil
    )

    key_result.raw_key
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def revoked?
    revoked_at.present?
  end

  # Get count of topics that match this beacon's configuration
  def document_count
    scope = Topic.active

    # Filter by beacon's language
    scope = scope.where(language_id: language_id) if language_id.present?

    # If beacon has specific providers selected, filter by those
    if providers.any?
      scope = scope.where(provider_id: providers.pluck(:id))
    else
      # If no providers selected, filter by providers in the beacon's region
      if region.present?
        provider_ids = region.providers.pluck(:id)
        scope = scope.where(provider_id: provider_ids)
      end
    end

    # If beacon has specific topics selected, filter by those
    if topics.any?
      scope = scope.where(id: topics.pluck(:id))
    end

    scope.count
  end

  # Get count of actual document files attached to matching topics
  def file_count
    scope = Topic.active

    scope = scope.where(language_id: language_id) if language_id.present?

    if providers.any?
      scope = scope.where(provider_id: providers.pluck(:id))
    elsif region.present?
      provider_ids = region.providers.pluck(:id)
      scope = scope.where(provider_id: provider_ids)
    end

    if topics.any?
      scope = scope.where(id: topics.pluck(:id))
    end

    # Count total attached documents
    scope.joins(:documents_attachments).count
  end
end
