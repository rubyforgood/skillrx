require "rails_helper"

RSpec.describe "users/index", type: :view do
  include Pagy::Frontend

  context "when there are no users" do
    before(:each) do
      assign(:pagy, Pagy.new(count: 0))
      assign(:users, [])
    end

    it "renders no users" do
      render
      assert_select "table>tbody>tr", count: 0
    end
  end

  context "when there are users but only one page" do
    before(:each) do
      assign(:pagy, Pagy.new(count: 1))
      assign(:users, [ create(:user, email: "user@test.local") ])
    end

    it "renders a list of users" do
      render
      assert_select "table>tbody>tr", count: 1
    end

    it "does not render pagination when only one page present" do
      render
      assert_select "nav[aria-label='Pages']", count: 0
    end
  end

  context "when there are multiple pages of users" do
    before(:each) do
      # Simulate being on page 2 with 10 items per page and 25 total items
      pagy = Pagy.new(count: 25, page: 2, limit: 10)
      assign(:pagy, pagy)
      assign(:users, create_list(:user, 10))
    end

    it "renders the current page of users" do
      render
      assert_select "table>tbody>tr", count: 10
    end

    it "renders pagination with multiple pages" do
      render
      assert_select "nav[aria-label='Pages'] a", count: 5 # Previous, 1, 2, 3, Next
      assert_select "nav[aria-label='Pages'] a[aria-current='page']", text: "2", count: 1
    end
  end
end
