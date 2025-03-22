require "rails_helper"

RSpec.describe "Creating a Region", type: :feature do
    describe "there is a Create Region button" do
      let(:user) { create(:user, email: "admin@mail.com", password: "test123", is_admin: true) }
      let(:region) { create(:region) }

      before do
        visit new_session_path
        fill_in "Enter your email address", with: user.email
        fill_in "Enter your password", with: user.password
        click_button "Sign in"
      end
    it "Creates a Region" do
      visit new_region_path(region)

      expect(page).to have_button("Create Region")
    end
  end
end
