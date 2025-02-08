require "rails_helper"

RSpec.describe "Training Resources", type: :request do
  describe "GET /training_resources" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it "renders a successful response" do
      create(:training_resource)

      get training_resources_url

      expect(response).to be_successful
      expect(assigns(:training_resources)).to eq(TrainingResource.all)
    end
  end
end
