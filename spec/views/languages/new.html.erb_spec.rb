require "rails_helper"

RSpec.describe "languages/new", type: :view do
  before(:each) do
    assign(:language, Language.new(name: "French"))
  end

  it "renders new language form" do
    render

    assert_select "form[action=?][method=?]", languages_path, "post" do
      assert_select "input[name=?]", "language[name]"
      assert_select "input[type='submit'][value='Create Language']"
    end
  end
end
