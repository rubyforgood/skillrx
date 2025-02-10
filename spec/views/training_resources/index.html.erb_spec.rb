require "rails_helper"

RSpec.describe "training_resources/index", type: :view do
  before(:each) do
    assign(:training_resources, [
      create(:training_resource, state: 1, file_name_override: "filename_1.jpg"),
      create(:training_resource, state: 2, file_name_override: "filename_2.jpg"),
    ],)
  end

  it "renders a list of training_resources" do
    create(:training_resource)

    cell_selector = "table>tbody>tr"

    render

    assert_select cell_selector, text: Regexp.new(/filename_/), count: 2
  end
end
