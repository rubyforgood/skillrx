# == Schema Information
#
# Table name: beacons
#
#  id           :bigint           not null, primary key
#  name         :string
#  location     :string
#  token        :string
#  last_seen_at :datetime
#  online       :boolean          default(FALSE)
#  version      :string
#  language_id  :bigint
#  provider_id  :bigint
#  region_id    :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_beacons_on_token        (token) UNIQUE
#  index_beacons_on_language_id  (language_id)
#  index_beacons_on_provider_id  (provider_id)
#  index_beacons_on_region_id    (region_id)
#
class Beacon < ApplicationRecord
  belongs_to :language, optional: true
  belongs_to :provider, optional: true
  belongs_to :region, optional: true
  has_many :beacon_tags, dependent: :destroy
  has_many :tags, through: :beacon_tags

  validates :name, presence: true
  validates :token, uniqueness: true, allow_nil: true

  before_create :generate_token

  # Get count of documents/topics that match this beacon's filters
  def document_count
    scope = Topic.active
    
    # Apply filters based on beacon configuration
    scope = scope.where(language_id: language_id) if language_id.present?
    scope = scope.where(provider_id: provider_id) if provider_id.present?
    
    # If region is set, filter topics by providers in that region
    if region_id.present?
      provider_ids = region.providers.pluck(:id)
      scope = scope.where(provider_id: provider_ids)
    end
    
    # If tags are set, filter topics that have any of those tags
    if tags.any?
      scope = scope.tagged_with(tags.pluck(:name), any: true)
    end
    
    scope.count
  end

  # Get count of actual document files attached to matching topics
  def file_count
    scope = Topic.active
    
    scope = scope.where(language_id: language_id) if language_id.present?
    scope = scope.where(provider_id: provider_id) if provider_id.present?
    
    if region_id.present?
      provider_ids = region.providers.pluck(:id)
      scope = scope.where(provider_id: provider_ids)
    end
    
    if tags.any?
      scope = scope.tagged_with(tags.pluck(:name), any: true)
    end
    
    # Count total attached documents
    scope.joins(:documents_attachments).count
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end
end
