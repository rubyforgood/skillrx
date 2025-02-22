# == Schema Information
#
# Table name: branches
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :bigint
#  region_id   :bigint
#
# Indexes
#
#  index_branches_on_provider_id  (provider_id)
#  index_branches_on_region_id    (region_id)
#
class Branch < ApplicationRecord
  belongs_to :provider
  belongs_to :region
end
