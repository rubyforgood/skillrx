class Topic < ApplicationRecord
  include Searcheable

  belongs_to :language
  belongs_to :provider
  has_many :training_resources

  validates :title, :language_id, :provider_id, presence: true

  STATES = %i[active archived].freeze

  enum :state, STATES.map.with_index.to_h

  scope :active, -> { where(state: :active) }
end
