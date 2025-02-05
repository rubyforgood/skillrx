require "rails_helper"

RSpec.describe "training_resources/edit", type: :view do
  let(:topic) { create(:topic) }
  let(:training_resource) {
    TrainingResource.create!(
      state: 1,
      document: nil,
      topic: topic,
      file_name_override: "test.jpg",
    )
  }

  before(:each) do
    assign(:training_resource, training_resource)
  end

  it "renders the edit training_resource form" do
    render

    assert_select "form[action=?][method=?]", training_resource_path(training_resource), "post" do
      assert_select "input[name=?]", "training_resource[state]"

      assert_select "input[name=?]", "training_resource[document]"
    end
  end
end
