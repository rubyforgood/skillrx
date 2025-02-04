module AuthenticationHelpers
  def sign_in(user)
    post session_url, params: { email: user.email, password: user.password }
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end
