require "rails_helper"

RSpec.describe "User Login", type: :system do
  let(:user) { create(:user) }

  before do
    visit root_path
    click_link("Sign In")
  end

  context "with correct email and password" do
    context "contributor" do
      it "logs in the user" do
        fill_in "email", with: user.email
        fill_in "password", with: user.password
        click_button("Sign in")

        expect(page).to have_text("Topic")
        expect(page).not_to have_text("Administration")
      end
    end

    context "administrator" do
      before { user.update(is_admin: true) }

      it "logs in the user" do
        fill_in "email", with: user.email
        fill_in "password", with: user.password
        click_button("Sign in")

        expect(page).to have_text("Topic")
        expect(page).to have_text("Administration")
        expect(page).to have_text("Regions")
        expect(page).to have_text("Providers")
        expect(page).to have_text("Languages")
        expect(page).to have_text("Users")
      end
    end
  end

  context "with incorrect email or password" do
    it "shows error message" do
      fill_in "email", with: "incorrectemail@mail.com"
      fill_in "password", with: user.password
      click_button("Sign in")

      expect(page).to have_text("Try another email address or password.")
    end
  end

  context "forgotten password" do
    it "allows users to reset password" do
      click_on("Forgot password?")
      expect(page).to have_text("Input your email and we will send you reset password link")
      expect(page).to have_link("Login", href: new_session_path)
    end
  end

  context "after logging in" do
    it "allows users to log out" do
      fill_in "email", with: user.email
      fill_in "password", with: user.password
      click_button("Sign in")
      click_button("Log out")
      expect(page).to have_button("Sign in")
    end
  end
end
