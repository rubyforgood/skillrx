require "rails_helper"

RSpec.describe "regions/index", type: :view do
  before(:each) do
    assign(
      :regions,
      [
        Region.create!(name: "Name"),
        Region.create!(name: "Name"),
      ],
    )
  end

  it "renders a list of regions" do
    render
    cell_selector = "table>tbody>tr"
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
  end
end
