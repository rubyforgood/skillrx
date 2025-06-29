require "rails_helper"

describe "Topics", type: :request do
  describe "PUT /topics/:id" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic) }

    before { sign_in(user) }

    it "archives a Topic" do
      put archive_topic_url(topic)

      expect(response).to redirect_to(topics_url)
      expect(topic.reload.state).to eq("archived")
    end

    context "when topic has documents" do
      let(:topic) { create(:topic, :with_documents) }
      let(:document) { topic.documents.first }

      before do
        allow(DocumentsSyncJob).to receive(:perform_later)
      end

      it "runs sync job for documents" do
        put archive_topic_url(topic)

        expect(response).to redirect_to(topics_url)
        expect(DocumentsSyncJob).to have_received(:perform_later).with(
          topic_id: topic.id,
          document_id: document.id,
          action: "archive",
        )
      end
    end
  end
end
