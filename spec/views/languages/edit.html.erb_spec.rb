require "rails_helper"

RSpec.describe "languages/edit", type: :view do
  let(:language) { create(:language) }

  before(:each) do
    assign(:language, language)
  end

  it "renders new language form" do
    render

    assert_select "form[action=?][method=?]", language_path(language), "post" do
      assert_select "input[name=?]", "language[name]"
      assert_select "input[type='submit'][value='Update Language']"
    end
  end
end
