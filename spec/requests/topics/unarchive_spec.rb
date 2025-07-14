require "rails_helper"

describe "Topics", type: :request do
  describe "PUT /topics/:id/unarchive" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic) }

    before { sign_in(user) }

    it "unarchives a Topic" do
      put unarchive_topic_url(topic)

      expect(response).to redirect_to(topics_url)
      expect(topic.reload.state).to eq("active")
    end

    context "when topic has documents" do
      let(:topic) { create(:topic, :with_documents, state: "archived") }

      before do
        allow(DocumentsSyncJob).to receive(:perform_later)
      end

      it "runs sync job for documents" do
        put unarchive_topic_url(topic)

        expect(response).to redirect_to(topics_url)
        expect(DocumentsSyncJob).to have_received(:perform_later).with(
          topic_id: topic.id,
          document_id: topic.documents.first.id,
          action: "unarchive",
        )
      end
    end
  end
end
