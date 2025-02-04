require "rails_helper"

describe "Topics", type: :request do
  describe "GET /topics" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it "renders a successful response" do
      create(:topic)

      get topics_url

      expect(response).to be_successful
      expect(assigns(:topics)).to eq(Topic.active)
    end
  end
end
