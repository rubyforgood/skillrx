class Branch < ApplicationRecord
  belongs_to :provider
  belongs_to :region
end
