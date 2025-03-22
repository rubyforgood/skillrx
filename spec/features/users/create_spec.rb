require "rails_helper"

RSpec.describe "Creating a User", type: :feature do
    describe "there is a Create user button" do
      let(:user) { create(:user, email: "admin@mail.com", password: "test123", is_admin: true) }

      before do
        visit new_session_path
        fill_in "Enter your email address", with: user.email
        fill_in "Enter your password", with: user.password
        click_button "Sign in"
      end
    it "Creates a User" do
      visit new_user_path

      expect(page).to have_button("Create User")
    end
  end
end
