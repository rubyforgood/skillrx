require "rails_helper"

RSpec.describe "Topics search", type: :system do
  let(:admin) { create(:user, :admin, email: "admin@mail.com") }
  let(:english) { create(:language, name: "English") }
  let(:spanish) { create(:language, name: "Spanish") }
  let!(:spanish_active_topic) { create(:topic, language: spanish, title: "Tratamiento del resfriado", created_at: Date.new(2025, 02, 03)) }
  let!(:english_active_topic) { create(:topic, language: english, title: "How to treat colds", description: "All the latest information about nasopharyngitis", created_at: Date.new(2025, 03, 04)) }
  let!(:english_archived_topic) { create(:topic, :archived, language: english, title: "Obsolete", created_at: Date.new(2023, 02, 01)) }

  before do
    login_as(admin)
    click_link("Topics")
  end

  it "shows all topics" do
    expect(page).to have_text(english_active_topic.title)
    expect(page).to have_text(spanish_active_topic.title)
    expect(page).to have_text(english_archived_topic.title)
  end

  context "when searching by title" do
    it "only displays topics matching the search" do
      fill_in "search_query", with: "tratamiento"

      expect(page).to have_text(spanish_active_topic.title)
      expect(page).not_to have_text(english_active_topic.title)
      expect(page).not_to have_text(english_archived_topic.title)
    end
  end

  context "when searching by description" do
    it "only displays topics matching the search" do
      fill_in "search_query", with: "pharyn"

      expect(page).to have_text(english_active_topic.title)
      expect(page).not_to have_text(spanish_active_topic.title)
      expect(page).not_to have_text(english_archived_topic.title)
    end
  end

  context "when searching by language" do
    it "only displays topics matching the search" do
      select "Spanish", from: "search_language_id"

      expect(page).to have_text(spanish_active_topic.title)
      expect(page).not_to have_text(english_active_topic.title)
      expect(page).not_to have_text(english_archived_topic.title)

      select "English", from: "search_language_id"

      expect(page).to have_text(english_active_topic.title)
      expect(page).to have_text(english_archived_topic.title)
      expect(page).not_to have_text(spanish_active_topic.title)
    end
  end

  context "when searching by year" do
    it "only displays topics matching the search" do
      select "2025", from: "search_year"

      expect(page).to have_text(spanish_active_topic.title)
      expect(page).to have_text(english_active_topic.title)
      expect(page).not_to have_text(english_archived_topic.title)

      select "2023", from: "search_year"

      expect(page).to have_text(english_archived_topic.title)
      expect(page).not_to have_text(spanish_active_topic.title)
      expect(page).not_to have_text(english_active_topic.title)
    end
  end

  context "when searching by month" do
    it "only displays topics matching the search" do
      select "2", from: "search_month"

      expect(page).to have_text(spanish_active_topic.title)
      expect(page).to have_text(english_archived_topic.title)
      expect(page).not_to have_text(english_active_topic.title)

      select "3", from: "search_month"

      expect(page).to have_text(english_active_topic.title)
      expect(page).not_to have_text(english_archived_topic.title)
      expect(page).not_to have_text(spanish_active_topic.title)
    end
  end

  context "when searching by state" do
    it "only displays topics matching the search" do
      select "active", from: "search_state"

      expect(page).to have_text(spanish_active_topic.title)
      expect(page).to have_text(english_active_topic.title)
      expect(page).not_to have_text(english_archived_topic.title)

      select "archived", from: "search_state"

      expect(page).to have_text(english_archived_topic.title)
      expect(page).not_to have_text(spanish_active_topic.title)
      expect(page).not_to have_text(english_active_topic.title)
    end
  end

  context "when sorting" do
    it "displays users in the selected order" do
      select "asc", from: "search_order"
      expect(page).to have_text(/#{english_archived_topic.title}.+#{spanish_active_topic.title}.+#{english_active_topic.title}/m)
    end
  end
end
