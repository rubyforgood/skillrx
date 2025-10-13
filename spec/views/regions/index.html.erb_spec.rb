require "rails_helper"

RSpec.describe "regions/index", type: :view do
  let!(:regions) { [ create(:region, name: "Region 1"), create(:region, name: "Region 2") ] }
  before(:each) do
    assign :regions, Region
      .left_joins(:providers)
      .select("regions.*, COUNT(providers.id) AS providers_count")
      .group("regions.id")
      .order(:name)
  end

  it "renders a list of regions" do
    render
    cell_selector = "table>tbody>tr"
    assert_select cell_selector, text: Regexp.new(/Region/), count: 2
  end
end
