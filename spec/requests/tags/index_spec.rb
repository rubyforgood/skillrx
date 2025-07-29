require "rails_helper"

describe "Tags", type: :request do
  describe "GET /tags" do
    let(:user) { create(:user, :admin) }

    before do
      sign_in(user)
    end

    it "renders a successful response" do
      tag = create(:tag)

      get tags_url

      expect(response).to be_successful
      expect(assigns(:tags)).to eq([ tag ])
    end
  end
end
