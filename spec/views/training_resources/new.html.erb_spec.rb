require 'rails_helper'

RSpec.describe "training_resources/new", type: :view do
  before(:each) do
    assign(:training_resource, TrainingResource.new(
      state: 1
    ))
  end

  it "renders new training_resource form" do
    render

    assert_select "form[action=?][method=?]", training_resources_path, "post" do

      assert_select "input[name=?]", "training_resource[state]"
    end
  end
end
