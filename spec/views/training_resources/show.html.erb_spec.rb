require "rails_helper"

RSpec.describe "training_resources/show", type: :view do
  before(:each) do
    assign(:training_resource, create(:training_resource))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2/)
    expect(rendered).to match(//)
  end
end
