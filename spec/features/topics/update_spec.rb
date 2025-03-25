require "rails_helper"

RSpec.describe "Editing a Topic", type: :feature do
    describe "there is a update topic button" do
      let(:user) { create(:user, email: "me@mail.com", password: "test123") }
      let(:topic) { create(:topic) }

      before do
        visit new_session_path
        fill_in "Enter your email address", with: user.email
        fill_in "Enter your password", with: user.password
        click_button "Sign in"
      end
    it "updates a Topic" do
      visit edit_topic_path(topic)

      expect(page).to have_button("Update Topic")
    end
  end
end
