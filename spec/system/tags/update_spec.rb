require "rails_helper"

RSpec.describe "Updating a Tag", type: :system do
  let(:user) { create(:user, :admin) }
  let(:tag) { create(:tag, name: "Cold") }
  let(:cognate) { create(:tag, name: "Nasopharyngitis") }

  before do
    login_as(user)
    create(:tag_cognate, tag: tag, cognate: cognate)
  end

  context "as an Admin" do
    let(:topic) { create(:topic, :tagged) }

    before do
      topic.tags.first.update(name: "Rhinopharyngitis")
    end

    it "updates the tag" do
      wait_and_visit(edit_tag_path(tag.id))
      fill_in "Name", with: "Common Cold"
      enter_and_choose_tag("Rhinopharyngitis")
      find("body").click

      click_button "Update Tag"
      visit(tag_path(tag))
      expect(page).to have_text("Common Cold")
      expect(page).to have_text("Nasopharyngitis")
      expect(page).to have_text("Rhinopharyngitis")
    end

    context "when the cognate entered doesn't already exist" do
      it "show an error" do
        wait_and_visit(edit_tag_path(tag.id))
        enter_and_choose_tag("URTI")

        expect(page).to have_text("Please select a tag from the list")
      end
    end
  end
end
