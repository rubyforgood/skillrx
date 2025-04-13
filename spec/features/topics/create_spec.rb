require "rails_helper"

RSpec.describe "Creating a Topic", type: :feature do
  describe "there is a create topic button" do
    let(:user) { create(:user, email: "me@mail.com", password: "test123") }
    let(:provider) { create(:provider) }
    let(:language) { create(:language) }
    let!(:topic) { build(:topic, provider:, language:) }

    before do
      provider.users << user

      visit new_session_path
      fill_in "Enter your email address", with: user.email
      fill_in "Enter your password", with: user.password
      click_button "Sign in"
    end

    it "creates a Topic" do
      expect(Topic.count).to eq(0)

      visit new_topic_path
      expect(page).to have_button("Create Topic")

      fill_in "Title", with: topic.title
      fill_in "Description", with: topic.description
      select language.name, from: "topic_language_id"
      select 2023, from: "topic_published_at_year"
      select 4, from: "topic_published_at_month"
      click_button "Create Topic"
      expect(page).to have_content(topic.title)
      expect(Topic.count).to eq(1)
      expect(Topic.first.published_at).to eq(Date.new(2023, 4, 1))
    end
  end
end
