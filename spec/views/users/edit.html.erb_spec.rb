require "rails_helper"

RSpec.describe "users/edit", type: :view do
  let(:user) { create(:user) }

  before(:each) do
    assign(:user, user)
  end

  it "renders new user form" do
    render

    assert_select "form[action=?][method=?]", user_path(user), "post" do
      assert_select "input[name=?]", "user[email]"
      assert_select "input[name=?]", "user[password]"
      assert_select "input[name=?]", "user[is_admin]"
      assert_select "input[name=?]", "user[provider_ids][]"
      assert_select "input[type='submit'][value='Update User']"
    end
  end
end
