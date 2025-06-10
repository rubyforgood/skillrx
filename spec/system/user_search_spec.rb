require "rails_helper"

RSpec.describe "User search", type: :system do
  let(:admin) { create(:user, :admin, email: "admin@mail.com", created_at: 3.days.ago) }
  let!(:martin) { create(:user, email: "martin@mail.com", created_at: 2.days.ago) }
  let!(:rosemary) { create(:user, email: "rosemary@mail.com", created_at: 1.day.ago) }

  before do
    login_as(admin)
    click_link("Users")
  end

  it "shows by default the users from most to least recently added" do
    expect(page).to have_text(/#{rosemary.email}.+#{martin.email}.+#{admin.email}/m)
  end

  context "when searching by email" do
    it "only displays users matching the search" do
      fill_in "search[email]", with: "mar"

      expect(page).to have_text(rosemary.email)
      expect(page).to have_text(martin.email)
      expect(page).not_to have_text(admin.email)
    end
  end

  context "when searching by role" do
    it "only displays users matching the search" do
      select "Admin", from: "search_is_admin"

      expect(page).to have_text(admin.email)
      expect(page).not_to have_text(rosemary.email)
      expect(page).not_to have_text(martin.email)

      select "Contributor", from: "search_is_admin"

      expect(page).to have_text(rosemary.email)
      expect(page).to have_text(martin.email)
      expect(page).not_to have_text(admin.email)
    end
  end

  context "when sorting" do
    it "displays users in the selected order" do
      select "By least recently added", from: "search_order"
      Capybara.using_wait_time(7) do
        expect(page).to have_text(/#{admin.email}.+#{martin.email}.+#{rosemary.email}/m)
      end
    end
  end
end
