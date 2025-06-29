require "rails_helper"

describe "Topics", type: :request do
  describe "DELETE /topics/:id" do
    let(:user) { create(:user, :admin) }
    let(:topic) { create(:topic) }

    before { sign_in(user) }

    it "deletes a Topic" do
      delete topic_url(topic)

      expect(response).to redirect_to(topics_url)
      expect(Topic.count).to be_zero
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it "does not delete a Topic" do
        delete topic_url(topic)

        expect(response).to redirect_to(topics_url)
        expect(Topic.count).to eq(1)
      end
    end

    context "when topic has documents" do
      let(:topic) { create(:topic, :with_documents) }
      let(:document) { topic.documents.first }

      before do
        allow(DocumentsSyncJob).to receive(:perform_later)
      end

      it "runs sync job for documents" do
        delete topic_url(topic)

        expect(response).to redirect_to(topics_url)
        expect(DocumentsSyncJob).to have_received(:perform_later).with(
          topic_id: topic.id,
          document_id: document.id,
          action: "delete",
        )
      end
    end
  end
end
