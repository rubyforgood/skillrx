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

  context "when the provider has associated topics" do
    before { create(:topic, provider: provider) }

    it "tells the user that the File name prefix can't be changed" do
      render

      assert_select "form[action=?][method=?]", provider_path(provider), "post" do
        assert_select "input[name=?][disabled]", "provider[file_name_prefix]"
      end

      assert_select "div#file-name-prefix-uneditable-notice"
    end
  end

  context "when the provider that has no associated topics" do
    it "has the File name prefix field" do
      render

      assert_select "form[action=?][method=?]", provider_path(provider), "post" do
        assert_select "input[name=?]", "provider[file_name_prefix]"
      end
    end
  end
end
