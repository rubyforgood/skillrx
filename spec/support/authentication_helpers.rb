module AuthenticationHelpers
  def sign_in(user)
    Current.session = user.sessions.create!
    cookies = ActionDispatch::Request.new(Rails.application.env_config).cookie_jar
    cookies.signed[:session_id] = { value: Current.session.id, httponly: true, same_site: :lax }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
