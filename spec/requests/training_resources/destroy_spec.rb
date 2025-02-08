require "rails_helper"

RSpec.describe "Training Resources", type: :request do
  describe "DELETE /destroy" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic) }
    let(:valid_attributes) { attributes_for(:training_resource, topic_id: topic.id) }

    before { sign_in(user) }

    it "destroys the requested training_resource" do
      training_resource = TrainingResource.create! valid_attributes
      expect {
        delete training_resource_url(training_resource)
      }.to change(TrainingResource, :count).by(-1)
    end

    it "redirects to the training_resources list" do
      training_resource = TrainingResource.create! valid_attributes
      delete training_resource_url(training_resource)
      expect(response).to redirect_to(training_resources_url)
    end
  end
end
