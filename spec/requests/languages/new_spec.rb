require "rails_helper"

describe "Languages", type: :request do
  describe "GET /languages/new" do
    let(:admin) { create(:user, :admin) }

    before { sign_in(admin) }

    it "renders a successful response" do
      get new_language_url
      expect(response).to be_successful
    end
  end
end
