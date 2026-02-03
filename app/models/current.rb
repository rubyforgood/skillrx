class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :device
  delegate :user, to: :session, allow_nil: true
end
