require "rails_helper"

RSpec.describe "Topics pagination", type: :system do
  let(:english) { create(:language, name: "English") }
  let(:provider) { create(:provider) }

  before do
    # Create enough topics to have multiple pages
    40.times do |i|
      create(:topic, :archived, language: english, title: "Archived Topic #{i}", provider: provider)
    end
    create(:topic, language: english, title: "Active Topic", provider: provider)

    login_as(create(:user, :admin))
    click_link("Topics")
  end

  it "preserves search filters when paginating" do
    select "archived", from: "search_state"

    # Ensure only archived topics are visible
    expect(page).to have_text("Archived Topic", count: 20)
    expect(page).not_to have_text("Active Topic")

    click_link("Next")

    expect(page).to have_text("Archived Topic", count: 20)
    expect(page).not_to have_text("Active Topic")
    expect(page.current_url).to include("search%5Bstate%5D=archived")
  end
end
