require "rails_helper"

RSpec.describe "topics/index", type: :view do
  before(:each) do
    def view.search_params = {}
    def view.topics_title = "Topics"

    # Allow the original render method to work normally
    allow(view).to receive(:render).and_call_original
    # But stub specifically the search partial render
    allow(view).to receive(:render).with("search", any_args).and_return("")

    assign(:available_providers, [])
  end

  context "when there are no topics" do
    before(:each) do
      assign(:pagy, Pagy::Offset.new(count: 0))
      assign(:topics, [])
    end

    it "renders no topics" do
      render
      assert_select "table>tbody>tr", count: 0
    end
  end

  context "when there are topics but only one page" do
    before(:each) do
      assign(:pagy, Pagy::Offset.new(count: 1))
      assign(:topics, [ create(:topic, title: "Topic 1") ])
    end

    it "renders a list of topics" do
      render
      assert_select "table>tbody>tr", count: 1
    end

    it "renders pagination nav with unique item" do
      render
      assert_dom "nav.pagy-bootstrap .page-item", text: "1", count: 1
    end
  end

  context "when there are multiple pages of topics" do
    before(:each) do
      # Simulate being on page 2 with 10 items per page and 25 total items
      pagy = Pagy::Offset.new(count: 25, page: 2, items: 10)
      assign(:pagy, pagy)
      assign(:topics, create_list(:topic, 10))
    end

    it "renders the current page of topics" do
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
