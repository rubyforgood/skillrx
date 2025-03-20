require "rails_helper"

RSpec.describe "Creating a Provider", type: :feature do
    describe "there is a Create Provider button" do
      let(:user) { create(:user, email: "admin@mail.com", password: "test123", is_admin: true) }
      let(:provider) { create(:provider) }

      before do
        visit new_session_path
        fill_in "Enter your email address", with: user.email
        fill_in "Enter your password", with: user.password
        click_button "Sign in"
      end
    it "Creates a Region" do
      visit new_provider_path(provider)

      expect(page).to have_button("Create Provider")
    end
  end
end
