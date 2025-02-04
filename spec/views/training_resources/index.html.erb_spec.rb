require 'rails_helper'

RSpec.describe "training_resources/index", type: :view do
  before(:each) do
    assign(:training_resources, [
      TrainingResource.create!(
        state: 2
      ),
      TrainingResource.create!(
        state: 2
      )
    ])
  end

  it "renders a list of training_resources" do
    render
    cell_selector = 'div>p'
    assert_select cell_selector, text: Regexp.new(2.to_s), count: 2
  end
end
