# == Schema Information
#
# Table name: contributors
# Database name: primary
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_contributors_on_provider_id  (provider_id)
#  index_contributors_on_user_id      (user_id)
#
class Contributor < ApplicationRecord
  belongs_to :provider
  belongs_to :user
end
