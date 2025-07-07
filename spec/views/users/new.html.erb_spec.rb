require "rails_helper"

RSpec.describe "users/new", type: :view do
  before(:each) do
    assign(:user, User.new)
  end

  it "renders new user form" do
    render

    assert_select "form[action=?][method=?]", users_path, "post" do
      assert_select "input[name=?]", "user[email]"
      assert_select "input[name=?]", "user[password]"
      assert_select "input[name=?]", "user[is_admin]"
      assert_select "input[name=?]", "user[provider_ids][]"
      assert_select "input[type='submit'][value='Create User']"
    end
  end
end
