require "rails_helper"

RSpec.describe "Training Resources", type: :request do
  describe "GET /training_resources/:id" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it "renders a successful response" do
      training_resource = create(:training_resource)

      get training_resource_url(training_resource)

      expect(response).to be_successful
    end
  end
end
