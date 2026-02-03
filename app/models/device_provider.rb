# == Schema Information
#
# Table name: device_providers
# Database name: primary
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  device_id   :bigint           not null
#  provider_id :bigint           not null
#
# Indexes
#
#  index_device_providers_on_device_id                  (device_id)
#  index_device_providers_on_device_id_and_provider_id  (device_id,provider_id) UNIQUE
#  index_device_providers_on_provider_id                (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (device_id => devices.id)
#  fk_rails_...  (provider_id => providers.id)
#
class DeviceProvider < ApplicationRecord
  belongs_to :device
  belongs_to :provider
end
