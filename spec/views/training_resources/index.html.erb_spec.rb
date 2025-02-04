require "rails_helper"

RSpec.describe "training_resources/index", type: :view do
  before(:each) do
    ts_1 = create(:training_resource)
    ts_2 = create(:training_resource)

    assign(:training_resources, [
      ts_1,ts_2
    ])
  end

  it "renders a list of training_resources" do
    render
    cell_selector = "div#training_resources>div"
    assert_select cell_selector, text: Regexp.new(/training_resource_/), count: 2
  end
end
