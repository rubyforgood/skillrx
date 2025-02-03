require 'rails_helper'

RSpec.describe "regions/new", type: :view do
  before(:each) do
    assign(:region, Region.new(
      name: "MyString"
    ))
  end

  it "renders new region form" do
    render

    assert_select "form[action=?][method=?]", regions_path, "post" do
      assert_select "input[name=?]", "region[name]"
    end
  end
end
