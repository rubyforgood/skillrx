require 'rails_helper'

RSpec.describe "providers/show", type: :view do
  before(:each) do
    assign(:provider, Provider.create!(
      name: "Name",
      provider_type: "Provider Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Provider Type/)
  end
end
