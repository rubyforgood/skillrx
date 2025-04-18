require "rails_helper"

RSpec.describe "home/index", type: :view do
  context "when not authenticated" do
    before { def view.authenticated? = false }

    it "displays link to the login page" do
      render
      expect(rendered).to have_link("Sign In", href: new_session_path)
    end
  end

  context "when authenticated" do
    before { def view.authenticated? = true }

    it "has button to sign out" do
      render
      expect(rendered).to have_button("Sign Out")
    end
  end
end
