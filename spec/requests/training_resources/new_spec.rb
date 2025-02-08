require "rails_helper"

RSpec.describe "Training Resources", type: :request do
  describe "GET /training_resources/new" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it "renders a successful response" do
      get new_training_resource_url

      expect(response).to be_successful
    end
  end
end
