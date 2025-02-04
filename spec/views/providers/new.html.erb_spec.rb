require 'rails_helper'

RSpec.describe "providers/new", type: :view do
  before(:each) do
    assign(:provider, Provider.new(
      name: "MyString",
      provider_type: "MyString"
    ))
  end

  it "renders new provider form" do
    render

    assert_select "form[action=?][method=?]", providers_path, "post" do

      assert_select "input[name=?]", "provider[name]"

      assert_select "input[name=?]", "provider[provider_type]"
    end
  end
end
