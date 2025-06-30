require "rails_helper"

describe "Languages", type: :request do
  describe "GET /languages/new" do
    let(:admin) { create(:user, :admin) }

    before { sign_in(admin) }

    it "renders a successful response" do
      get new_language_url
      expect(response).to be_successful
    end

    it "displays a 'Create Language' button" do
      get new_language_url
      expect(page).to have_button("Create Language")
    end
  end
end
