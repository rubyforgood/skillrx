require "rails_helper"

RSpec.describe "tags/index", type: :view do
  context "when there are no tags" do
    before(:each) do
      assign(:pagy, Pagy::Offset.new(count: 0))
      assign(:tags, [])
    end

    it "renders no tags" do
      render
      assert_select "table>tbody>tr", count: 0
    end
  end

  context "when there are tags but only one page" do
    before(:each) do
      assign(:pagy, Pagy::Offset.new(count: 1))
      assign(:tags, [ create(:tag, name: "Tag 1") ])
    end

    it "renders a list of tags" do
      render
      assert_select "table>tbody>tr", count: 1
    end

    it "renders pagination nav without page links" do
      render
      assert_dom "nav.pagy-bootstrap .page-link", text: "1", count: 1
    end
  end

  context "when there are multiple pages of tags" do
    before(:each) do
      # Simulate being on page 2 with 10 items per page and 25 total items
      pagy = Pagy::Offset.new(count: 25, page: 2, items: 10)
      assign(:pagy, pagy)
      assign(:tags, create_list(:tag, 10))
    end

    it "renders the current page of tags" do
      render
      assert_select "table>tbody>tr", count: 10
    end

    it "renders pagination with multiple pages" do
      render
      assert_select "nav.pagy-bootstrap .page-item", minimum: 2
      assert_dom "nav.pagy-bootstrap .page-item.active", text: "2", count: 1
    end
  end
end
