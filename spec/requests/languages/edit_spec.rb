require "rails_helper"

describe "Languages", type: :request do
  describe "GET /languages/:id/edit" do
    let(:admin) { create(:user, :admin) }
    let(:language) { create(:language) }

    before { sign_in(admin) }

    it "renders a successful response" do
      get edit_language_url(language)
      expect(response).to be_successful
    end

    it "displays a 'Create Language' button" do
      get edit_language_url(language)
      expect(page).to have_button("Update Language")
    end
  end
end
