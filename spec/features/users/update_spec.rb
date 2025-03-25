require "rails_helper"

RSpec.describe "Updating a User", type: :feature do
    describe "there is a Update User button" do
      let(:user) { create(:user, email: "admin@mail.com", password: "test123", is_admin: true) }
      let(:other_user) { create(:user, email: "me@mail.com", password: "test123") }

      before do
        visit new_session_path
        fill_in "Enter your email address", with: user.email
        fill_in "Enter your password", with: user.password
        click_button "Sign in"
      end
    it "Updates a User" do
      visit edit_user_path(other_user)

      expect(page).to have_button("Update User")
    end
  end
end
