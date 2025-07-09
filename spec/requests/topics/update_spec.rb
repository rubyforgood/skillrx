require "rails_helper"

describe "Topics", type: :request do
  describe "PUT /topics/:id" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic) }

    before { sign_in(user) }

    it "updates a Topic" do
      topic_params = { title: "new topic", description: "updated" }

      put topic_url(topic), params: { topic: topic_params }

      topic.reload
      expect(response).to redirect_to(topics_url)
      expect(topic.title).to eq("new topic")
      expect(topic.description).to eq("updated")
    end

    context "when topic has documents" do
      let(:topic) { create(:topic, :with_documents) }
      let(:document) { topic.documents.first }

      before do
        allow(DocumentsSyncJob).to receive(:perform_later)
      end

      context "when new documents is added" do
        it "runs sync job for documents" do
          blob = ActiveStorage::Blob.create_and_upload!(
            io: File.open(Rails.root.join("spec", "fixtures", "files", "dummy.pdf")),
            filename: "dummy.pdf",
            content_type: "application/pdf",
          )
          topic_params = { title: "new topic with documents", document_signed_ids: [ blob.signed_id ] }
          expect(DocumentsSyncJob).to receive(:perform_later).with(
            hash_including(document_id: document.id, action: "delete"),
          )
          expect(DocumentsSyncJob).to receive(:perform_later).with(
            topic_id: topic.id,
            document_id: topic.documents.last.id,
            action: "update",
          )

          put topic_url(topic), params: { topic: topic_params }

          topic.reload
          expect(response).to redirect_to(topics_url)
          expect(topic.documents.count).to eq(1)
          expect(topic.documents.last.filename.to_s).to eq("dummy.pdf")
        end
      end
    end
  end
end
