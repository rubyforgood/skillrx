require "rails_helper"

RSpec.describe "home/index", type: :view do
  context "when not authenticated" do
    before { def view.authenticated? = false }

    it "displays link to the login page" do
      render
      expect(rendered).to have_link("Sign in", href: new_session_path)
    end

    # A button says what it does; the address is text beside it, readable and copyable.
    it "labels the contact buttons with the action and shows the address as text" do
      render
      expect(rendered).to have_link("Contact us", href: "mailto:contact@skillrx.org", count: 2)
      expect(rendered).not_to have_link(text: /Email contact@/)
      expect(rendered).to have_css(".site-contact-address", text: "or email contact@skillrx.org")
    end
  end

  context "when authenticated" do
    before { def view.authenticated? = true }

    it "displays link to the dashboard" do
      render
      expect(rendered).to have_link("Dashboard", href: topics_path)
    end

    it "has button to sign out" do
      render
      expect(rendered).to have_button("Sign out")
    end
  end
end
