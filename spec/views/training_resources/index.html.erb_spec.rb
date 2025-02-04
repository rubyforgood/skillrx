require "rails_helper"

RSpec.describe "training_resources/index", type: :view do
  before(:each) do
    assign(:training_resources, [
      create(:training_resource, state: 1),
      create(:training_resource, state: 2)
    ])
  end

  it "renders a list of training_resources" do
    cell_selector = "table>tbody>tr"
    render
    assert_select cell_selector, text: Regexp.new(/State:/), count: 2
  end
end
