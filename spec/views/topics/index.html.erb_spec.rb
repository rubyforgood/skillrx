require "rails_helper"

RSpec.describe "topics/index", type: :view do
  include Pagy::Frontend

  let(:request) do
    request_hash = { base_url: "http://test.host", path: "/topics", params: {}, cookie: nil }
    Pagy::Request.new(request: request_hash)
  end

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
      assign(:pagy, Pagy::Offset.new(count: 0, request:))
      assign(:topics, [])
    end

    it "renders no topics" do
      render
      assert_select "table>tbody>tr", count: 0
    end
  end

  context "when there are topics but only one page" do
    before(:each) do
      assign(:pagy, Pagy::Offset.new(count: 1, request:))
      assign(:topics, [ create(:topic, title: "Topic 1") ])
    end

    it "renders a list of topics" do
      render
      assert_select "table>tbody>tr", count: 1
    end

    it "does not render pagination when only one page present" do
      render
      assert_select "nav[aria-label='Pages']", count: 0
    end
  end

  context "when there are multiple pages of topics" do
    before(:each) do
      # Simulate being on page 2 with 10 items per page and 25 total items
      pagy = Pagy::Offset.new(count: 25, page: 2, items: 10, request:)
      assign(:pagy, pagy)
      assign(:topics, create_list(:topic, 10))
    end

    it "renders the current page of topics" do
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
