require "rails_helper"

RSpec.describe "Updating a Tag", type: :system do
  let(:user) { create(:user, :admin) }
  let(:tag) { create(:tag, name: "Python") }
  let(:cognate) { create(:tag, name: "Cython") }

  before do
    login_as(user)
    create(:tag_cognate, tag: tag)
    wait_and_visit(edit_tag_path(tag.id))
  end

  context "as an Admin" do
    it "updates a tag" do
      fill_in "Name", with: "JavaScript"
      enter_and_choose_tag("TypeScript")

      click_button "Update Tag"
      expect(page).to have_content("JavaScript")
      expect(page).to have_content("TypeScript")
    end
  end
end
