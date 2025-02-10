require "rails_helper"

RSpec.describe "Training Resources", type: :request do
  describe "PATCH /training_resources" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic) }
    let(:valid_attributes) { attributes_for(:training_resource, topic_id: topic.id) }
    let(:invalid_attributes) { { document: "", file_name_override: "", state: "", topic_id: "" } }

    before { sign_in(user) }

    context "with valid parameters" do
      let(:new_attributes) {
        { state: 1 }
      }

      it "updates the requested training_resource" do
        training_resource = TrainingResource.create! valid_attributes
        patch training_resource_url(training_resource), params: { training_resource: new_attributes }
        training_resource.reload
        expect(response).to redirect_to(training_resource_url(training_resource))
      end

      it "redirects to the training_resource" do
        training_resource = TrainingResource.create! valid_attributes
        patch training_resource_url(training_resource), params: { training_resource: new_attributes }
        training_resource.reload
        expect(response).to redirect_to(training_resource_url(training_resource))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        training_resource = TrainingResource.create! valid_attributes
        patch training_resource_url(training_resource), params: { training_resource: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
