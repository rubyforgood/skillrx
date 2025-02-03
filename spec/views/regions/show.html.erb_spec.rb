require 'rails_helper'

RSpec.describe "regions/show", type: :view do
  before(:each) do
    assign(:region, Region.create!(
      name: "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
  end
end
