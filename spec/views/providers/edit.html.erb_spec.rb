require "rails_helper"

RSpec.describe "providers/edit", type: :view do
  let(:provider) { create(:provider) }

  before(:each) do
    assign(:provider, provider)
  end

  it "renders the edit provider form" do
    render

    assert_select "form[action=?][method=?]", provider_path(provider), "post" do
      assert_select "input[name=?]", "provider[name]"
      assert_select "input[name=?]", "provider[provider_type]"
      assert_select "input[type='submit'][value='Update Provider']"
    end
  end
end
