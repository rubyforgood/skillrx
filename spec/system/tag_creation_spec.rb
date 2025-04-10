require "rails_helper"

RSpec.describe "Creating a Tag", type: :system do
  let(:user) { create(:user, :admin) }

  before do
    login_as(user)
    wait_and_visit(new_tag_path)
  end

  context "as an Admin" do
    it "creates a tag" do
      fill_in "Name", with: "Erlang"
      enter_and_choose_tag("OTP")

      click_button "Create Tag"
      expect(page).to have_content("Erlang")
      expect(page).to have_content("OTP")
    end
  end
end
