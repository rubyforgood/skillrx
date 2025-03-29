module SystemHelpers
  def login_as(user)
    visit root_path
    click_link("Sign In")
    fill_in "email", with: user.email
    fill_in "password", with: user.password
    click_button("Sign in")
  end

  def visit_with_wait(path)
    sleep(0.5)
    visit path
  end
end
