# == Schema Information
#
# Table name: beacons
# Database name: primary
#
#  id                :bigint           not null, primary key
#  api_key_digest    :string           not null
#  api_key_prefix    :string           not null
#  manifest_checksum :string
#  manifest_data     :jsonb
#  manifest_version  :integer          default(0), not null
#  name              :string           not null
#  revoked_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  language_id       :bigint           not null
#  region_id         :bigint           not null
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

  def revoke!
    update!(revoked_at: Time.current)
  end

  def revoked?
    revoked_at.present?
  end
end
