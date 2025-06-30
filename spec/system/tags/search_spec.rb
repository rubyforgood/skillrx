require "rails_helper"

RSpec.describe "Tag search", type: :system do
  let(:admin) { create(:user, :admin) }
  let!(:tag_1) { create(:tag, name: "Acupuncture", created_at: 3.days.ago, taggings_count: 2) }
  let!(:tag_2) { create(:tag, name: "Macular Degeneration", created_at: 1.day.ago, taggings_count: 1) }
  let!(:tag_3) { create(:tag, name: "Transplant", created_at: 2.days.ago, taggings_count: 3) }

  before do
    login_as(admin)
    click_link("Tags")
  end

  it "shows by default the tags in alphabetical order" do
    expect(page).to have_text(/Acupuncture.+Macular Degeneration.+Transplant/m)
  end

  context "when searching by name" do
    it "only displays tags matching the search" do
      fill_in "search[name]", with: "acu"

      expect(page).to have_text("Acupuncture")
      expect(page).to have_text("Macular Degeneration")
      expect(page).not_to have_text("Transplant")
    end
  end

  context "when sorting by most recently added" do
    it "displays tags in the selected order" do
      select "Most recently added", from: "search_order"
      expect(page).to have_text(/#{tag_2.name}.+#{tag_3.name}.+#{tag_1.name}/m)
    end
  end

  context "when sorting by least recently added" do
    it "displays tags in the selected order" do
      select "Least recently added", from: "search_order"
      expect(page).to have_text(/#{tag_1.name}.+#{tag_3.name}.+#{tag_2.name}/m)
    end
  end

  context "when sorting by highest number of taggings" do
    it "displays tags in the selected order" do
      select "Highest number of taggings", from: "search_order"
      expect(page).to have_text(/#{tag_3.name}.+#{tag_1.name}.+#{tag_2.name}/m)
    end
  end

  context "when sorting by lowest number of taggings" do
    it "displays tags in the selected order" do
      select "Lowest number of taggings", from: "search_order"
      expect(page).to have_text(/#{tag_2.name}.+#{tag_1.name}.+#{tag_3.name}/m)
    end
  end
end
