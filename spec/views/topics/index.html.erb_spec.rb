require "rails_helper"

RSpec.describe "topics/index", type: :view do
  include Pagy::Frontend

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
      assign(:pagy, Pagy.new(count: 0))
      assign(:topics, [])
    end

    it "renders no topics" do
      render
      assert_select "table>tbody>tr", count: 0
    end
  end

  context "when there are topics but only one page" do
    before(:each) do
      assign(:pagy, Pagy.new(count: 1))
      assign(:topics, [ create(:topic, title: "Topic 1") ])
    end

    it "renders a list of topics" do
      render
      assert_select "table>tbody>tr", count: 1
    end

    it "does not render pagination when only one page present" do
      render
      assert_select "nav[aria-label='Page navigation']", count: 0
    end
  end

  context "when there are multiple pages of topics" do
    before(:each) do
      # Simulate being on page 2 with 10 items per page and 25 total items
      pagy = Pagy.new(count: 25, page: 2, limit: 10)
      assign(:pagy, pagy)
      assign(:topics, create_list(:topic, 10))
    end

    it "renders the current page of topics" do
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
