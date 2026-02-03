# == Schema Information
#
# Table name: devices
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
#
# Indexes
#
#  index_devices_on_api_key_digest  (api_key_digest) UNIQUE
#  index_devices_on_language_id     (language_id)
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#
class Device < ApplicationRecord
  belongs_to :language

  has_many :device_providers, dependent: :destroy
  has_many :providers, through: :device_providers

  has_many :device_topics, dependent: :destroy
  has_many :topics, through: :device_topics

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
