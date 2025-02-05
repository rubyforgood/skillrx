require "rails_helper"

describe "Languages", type: :request do
  describe "GET /languages" do
    let(:user) { create(:user, :admin) }

    before { sign_in(user) }

    it "renders a successful response" do
      create(:language)

      get languages_url

      expect(response).to be_successful
      expect(assigns(:languages)).to eq(Language.all)
    end
  end
end
