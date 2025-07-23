require "rails_helper"

describe "Topics", type: :request do
  describe "PUT /topics/:id/archive" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic) }

    before { sign_in(user) }

    it "archives a Topic" do
      put archive_topic_url(topic)

      expect(response).to redirect_to(topics_url)
      expect(topic.reload.state).to eq("archived")
    end

    it "displays a success message" do
      put archive_topic_url(topic)

      expect(flash[:notice]).to eq("Topic was successfully archived.")
    end

    context "when topic has documents" do
      let(:topic) { create(:topic, :with_documents) }

      before do
        allow(DocumentsSyncJob).to receive(:perform_later)
      end

      it "runs sync job for documents" do
        put archive_topic_url(topic)

        expect(response).to redirect_to(topics_url)
        expect(DocumentsSyncJob).to have_received(:perform_later).with(
          topic_id: topic.id,
          document_id: topic.documents.first.id,
          action: "archive",
        )
      end
    end
  end
end
