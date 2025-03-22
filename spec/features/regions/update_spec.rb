require "rails_helper"

RSpec.describe "Editing a Region", type: :feature do
    describe "there is a update Region button" do
      let(:user) { create(:user, email: "admin@mail.com", password: "test123", is_admin: true) }
      let(:region) { create(:region) }

      before do
        visit new_session_path
        fill_in "Enter your email address", with: user.email
        fill_in "Enter your password", with: user.password
        click_button "Sign in"
      end
    it "updates a Region" do
      visit edit_region_path(region)

      expect(page).to have_button("Update Region")
    end
  end
end
