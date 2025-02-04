class Topic < ApplicationRecord
  belongs_to :language
  belongs_to :provider
  has_many :taggings
  has_many :training_resources

  validates :title, presence: true
  validates :language_id, presence: true
  validates :provider_id, presence: true

  scope :archived, -> { where(archived: true) }
end
