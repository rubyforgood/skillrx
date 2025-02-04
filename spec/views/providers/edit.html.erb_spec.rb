require "rails_helper"

RSpec.describe "providers/edit", type: :view do
  let(:provider) { create(:provider) }
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  before do
    allow(Current).to receive(:user).and_return(user)
  end

  before(:each) do
    assign(:provider, provider)
  end

  it "renders the edit provider form" do
    render

    assert_select "form[action=?][method=?]", provider_path(provider), "post" do
      assert_select "input[name=?]", "provider[name]"
      assert_select "input[name=?]", "provider[provider_type]"
    end
  end

  it "does not render the contributor form group for common user" do
    render

    assert_select "form[action=?][method=?]", provider_path(provider), "post" do
      assert_select "select[id=?]", "provider_user_ids", false
    end
  end

  describe "for admin" do
    before do
      allow(Current).to receive(:user).and_return(admin)
    end

    it "renders the contributor form group" do
      render

      assert_select "form[action=?][method=?]", provider_path(provider), "post" do
        assert_select "select[id=?]", "provider_user_ids"
      end
    end
  end
end
