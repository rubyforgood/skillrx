class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :beacon
  attribute :feature_overrides
  delegate :user, to: :session, allow_nil: true
end
