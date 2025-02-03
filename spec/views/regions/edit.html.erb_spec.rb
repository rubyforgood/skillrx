require 'rails_helper'

RSpec.describe "regions/edit", type: :view do
  let(:region) {
    Region.create!(
      name: "MyString"
    )
  }

  before(:each) do
    assign(:region, region)
  end

  it "renders the edit region form" do
    render

    assert_select "form[action=?][method=?]", region_path(region), "post" do
      assert_select "input[name=?]", "region[name]"
    end
  end
end
