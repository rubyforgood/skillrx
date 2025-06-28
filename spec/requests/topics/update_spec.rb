require "rails_helper"

describe "Topics", type: :request do
  describe "PUT /topics/:id" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic) }

    before { sign_in(user) }

    it "updates a Language" do
      topic_params = { title: "new topic", description: "updated" }

      put topic_url(topic), params: { topic: topic_params }

      topic.reload
      expect(response).to redirect_to(topics_url)
      expect(topic.title).to eq("new topic")
      expect(topic.description).to eq("updated")
    end

    context "when topic has documents" do
      let(:document) { create(:document, topic: topic) }

      before do
        topic.documents << document
        allow(DocumentSyncJob).to receive(:perform_later)
      end

      context "when documents are changed" do
        it "runs sync job for documents" do
          new_document = fixture_file_upload("files/sample.pdf", "application/pdf")
          topic_params = { title: "new topic with documents", document_signed_ids: [ new_document.signed_id ] }

          put topic_url(topic), params: { topic: topic_params }

          topic.reload
          expect(response).to redirect_to(topics_url)
          # expect(topic.documents.count).to eq(1)
          # expect(topic.documents.first.filename.to_s).to eq("sample.pdf")
          expect(DocumentSyncJob).to have_received(:perform_later).with(
            topic_id: topic.id,
            document_id: topic.documents.first.id,
            action: "update",
          )
        end
      end
    end
  end
end
