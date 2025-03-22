require "rails_helper"

RSpec.describe "Updating a Language", type: :feature do
    describe "there is a Update Language button" do
      let(:user) { create(:user, email: "admin@mail.com", password: "test123", is_admin: true) }
      let(:language) { create(:language) }

      before do
        visit new_session_path
        fill_in "Enter your email address", with: user.email
        fill_in "Enter your password", with: user.password
        click_button "Sign in"
      end
    it "Creates a Language" do
      visit edit_language_path(language)

      expect(page).to have_button("Update Language")
    end
  end
end
