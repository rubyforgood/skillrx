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
  end
end
