require "rails_helper"

RSpec.describe "Training Resources", type: :request do
  describe "POST /training_resources" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic) }
    let(:valid_attributes) { attributes_for(:training_resource, topic_id: topic.id) }
    let(:invalid_attributes) { { document: "", file_name_override: "", state: "", topic_id: "" } }

    before { sign_in(user) }

    context "with valid parameters" do
      it "creates a new TrainingResource" do
        expect {
          post training_resources_url, params: { training_resource: valid_attributes }
        }.to change(TrainingResource, :count).by(1)
      end

      it "redirects to the created training_resource" do
        post training_resources_url, params: { training_resource: valid_attributes }
        expect(response).to redirect_to(training_resource_url(TrainingResource.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new TrainingResource" do
        expect {
          post training_resources_url, params: { training_resource: invalid_attributes }
        }.to change(TrainingResource, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post training_resources_url, params: { training_resource: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with file_name_override present" do
      it "does not create a new TrainingResource if there is already a preexistent entry with the same language" do
        preexistent_topic = create(:topic, language_id: topic.language_id)
        TrainingResource.create! valid_attributes

        post training_resources_url, params: { training_resource: valid_attributes.merge(topic_id: preexistent_topic.id) }

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "creates a new Training Resource if file_name_override has a different language" do
        preexistent_topic = create(:topic)
        TrainingResource.create! valid_attributes

        post training_resources_url, params: { training_resource: valid_attributes.merge(topic_id: preexistent_topic.id) }

        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
