require "rails_helper"

RSpec.describe "Deleting a Tag", type: :system do
  let(:user) { create(:user, :admin) }
  let(:tag) { create(:tag, name: "Tool") }

  before do
    login_as(user)
    wait_and_visit(tag_path(tag))
  end

  context "as an Admin" do
    it "deletes a tag" do
      click_button "Delete this tag"
      expect(page).to have_content("Are you sure you want to delete this tag?")

      click_button "Delete"
      expect(page).to have_content("Tag was successfully destroyed.")

      expect(page).to have_content("Tags")
      expect(page).not_to have_content("Tool")
    end
  end
end
