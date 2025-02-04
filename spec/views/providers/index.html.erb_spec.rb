require "rails_helper"

RSpec.describe "providers/index", type: :view do
  before(:each) do
    assign(:providers, [
      Provider.create!(
        name: "Name",
        provider_type: "Provider Type",
      ),
      Provider.create!(
        name: "Name",
        provider_type: "Provider Type",
      ),
    ],)
  end

  it "renders a list of providers" do
    render
    cell_selector = "table>tbody>tr"
    assert_select cell_selector, text: Regexp.new("Name".to_s), count: 2
    assert_select cell_selector, text: Regexp.new("Provider Type".to_s), count: 2
  end
end
