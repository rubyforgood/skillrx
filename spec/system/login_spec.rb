require "rails_helper"

RSpec.describe "User Login", type: :system do
  let(:user) { create(:user) }

  before do
    visit root_path
    click_link("Sign in")
  end

  context "with correct email and password" do
    context "contributor" do
      it "logs in the user" do
        fill_in "email", with: user.email
        fill_in "password", with: user.password
        click_button("Sign in")

        expect(page).to have_text("Topic")
        expect(page).not_to have_text("Administration")
      end
    end

    context "administrator" do
      before { user.update(is_admin: true) }

      it "logs in the user" do
        fill_in "email", with: user.email
        fill_in "password", with: user.password
        click_button("Sign in")

        expect(page).to have_text("Topic")
        expect(page).to have_text("Administration")
        expect(page).to have_text("Regions")
        expect(page).to have_text("Providers")
        expect(page).to have_text("Languages")
        expect(page).to have_text("Users")
      end
    end
  end

  context "with incorrect email or password" do
    it "shows error message" do
      fill_in "email", with: "incorrectemail@mail.com"
      fill_in "password", with: user.password
      click_button("Sign in")

      expect(page).to have_text("Try another email address or password.")
    end
  end

  context "forgotten password" do
    it "allows users to reset password" do
      click_on("Forgot your password?")
      expect(page).to have_text("We'll email you a link to choose a new password.")
      expect(page).to have_link("Sign in", href: new_session_path)
    end
  end

  context "after logging in" do
    it "allows users to sign out from the account menu" do
      fill_in "email", with: user.email
      fill_in "password", with: user.password
      click_button("Sign in")
      # The account menu's trigger is an <rfg-button>, whose real <button> is in its shadow root.
      find(".shell-account rfg-button").click
      find("[role=menuitem]", text: "Sign out").click
      expect(page).to have_button("Sign in")
    end
  end
end
