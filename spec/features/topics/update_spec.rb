require "rails_helper"

RSpec.describe "Editing a Topic", type: :feature do
  describe "there is a update topic button" do
    let(:user) { create(:user, email: "me@mail.com", password: "test123") }
    let(:provider) { create(:provider) }
    let(:language) { create(:language) }
    let!(:topic) { create(:topic, provider:, language:) }

    before do
      provider.users << user

      visit new_session_path
      fill_in "Enter your email address", with: user.email
      fill_in "Enter your password", with: user.password
      click_button "Sign in"
    end

    it "updates a Topic" do
      expect(Topic.count).to eq(1)

      visit edit_topic_path(topic)
      expect(page).to have_button("Update Topic")

      select 2024, from: "topic_published_at_year"
      select 3, from: "topic_published_at_month"
      click_button "Update Topic"
      expect(page).to have_content(topic.title)
      expect(Topic.count).to eq(1)
      expect(Topic.first.published_at).to eq(Date.new(2024, 3, 1))
    end
  end
end
