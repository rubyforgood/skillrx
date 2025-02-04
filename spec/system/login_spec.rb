require "rails_helper"

RSpec.describe "User Login", type: :system do
  let!(:user) { create(:user) }

  # context "with correct email and password" do
  #   it "logs in the user" do
  #     visit new_session_path
  #     fill_in "email", with: user.email
  #     fill_in "password", with: user.password
  #     click_button("Sign in")

  #     # will probably need to be amended once we have a page for non-Admin users
  #     expect(page).to have_text("Administration")
  #   end
  # end

  context "with incorrect email or password" do
    it "shows error message" do
      visit new_session_path
      fill_in "email", with: "incorrectemail@mail.com"
      fill_in "password", with: user.password
      click_button("Sign in")

      expect(page).to have_text("Try another email address or password.")
    end
  end

  context "forgotten password" do
    it "allows users to reset password" do
      visit new_session_path
      click_on("Forgot password?")
      expect(page).to have_text("Input your email and we will send you reset password link")
      expect(page).to have_link("Login", href: new_session_path)
    end
  end
end
