require "rails_helper"

RSpec.describe "regions/index", type: :view do
  before(:each) do
    assign(:regions, [create(:region, name: "Region 1"), create(:region, name: "Region 2")])
  end

  it "renders a list of regions" do
    render
    cell_selector = "table>tbody>tr"
    assert_select cell_selector, text: Regexp.new(/Region/), count: 2
  end
end
