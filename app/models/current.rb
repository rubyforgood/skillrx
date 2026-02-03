class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :beacon
  delegate :user, to: :session, allow_nil: true
end
