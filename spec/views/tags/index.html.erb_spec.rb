require "rails_helper"

RSpec.describe "tags/index", type: :view do
  include Pagy::Frontend

  context "when there are no tags" do
    before(:each) do
      assign(:pagy, Pagy.new(count: 0))
      assign(:tags, [])
    end

    it "renders no tags" do
      render
      assert_select "table>tbody>tr", count: 0
    end
  end

  context "when there are tags but only one page" do
    before(:each) do
      assign(:pagy, Pagy.new(count: 1))
      assign(:tags, [ create(:tag, name: "Tag 1") ])
    end

    it "renders a list of tags" do
      render
      assert_select "table>tbody>tr", count: 1
    end

    it "does not render pagination when only one page present" do
      render
      assert_select "nav[aria-label='Page navigation']", count: 0
    end
  end

  context "when there are multiple pages of tags" do
    before(:each) do
      # Simulate being on page 2 with 10 items per page and 25 total items
      pagy = Pagy.new(count: 25, page: 2, limit: 10)
      assign(:pagy, pagy)
      assign(:tags, create_list(:tag, 10))
    end

    it "renders the current page of tags" do
      render
      assert_select "table>tbody>tr", count: 10
    end

    it "renders pagination with multiple pages" do
      render
      assert_select "nav[aria-label='Page navigation'] ul li", count: 5 # Previous, 1, 2, 3, Next
      assert_select "nav[aria-label='Page navigation'] ul li span[aria-current='page']", text: "2", count: 1
    end
  end
end
