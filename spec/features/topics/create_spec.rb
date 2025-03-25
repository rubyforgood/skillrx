require "rails_helper"

RSpec.describe "Creating a Topic", type: :feature do
    describe "there is a create topic button" do
      let(:user) { create(:user, email: "me@mail.com", password: "test123") }
      let(:topic) { create(:topic) }

      before do
        visit new_session_path
        fill_in "Enter your email address", with: user.email
        fill_in "Enter your password", with: user.password
        click_button "Sign in"
      end
    it "creates a Topic" do
      visit new_topic_path(topic)

      expect(page).to have_button("Create Topic")
    end
  end
end
