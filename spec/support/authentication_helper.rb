module AuthHelper
  def sign_in(user)
    post session_path, params: { email: user.email, password: user.password }
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
