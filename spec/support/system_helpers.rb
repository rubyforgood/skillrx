module SystemHelpers
  def login_as(user)
    visit new_session_path
    fill_in "Enter your email address", with: user.email
    fill_in "Enter your password", with: user.password
    click_button "Sign in"
  end

  def wait_and_visit(path)
    sleep(0.5)
    visit path
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
end
