require "rails_helper"

RSpec.describe "Topics", type: :request do
  let(:user) { create(:user) }
  let(:provider) { create(:provider) }
  let(:language) { create(:language) }
  let!(:topic) { create(:topic, provider: provider, language: language) }

  before { sign_in(user) }

  describe "PUT /topics/:id" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic) }

    it "updates a Topic" do
       topic_params = { title: "new topic", description: "updated" }

       put topic_url(topic), params: { topic: topic_params }

       topic.reload
       expect(topic.title).to eq("new topic")
       expect(topic.description).to eq("updated")
    end

    context "when removing a tag" do
      let!(:tag) { create(:tag, name: "Tag to remove") }

      before do
        topic.set_tag_list_on(topic.language.code.to_sym, tag.name)
        topic.save
      end

      context "when the tag is not used on any other topic" do
        let(:topic_params) {  { tag_list: [ "" ] } }

        it "removes the tag from the topic and destroys the unused tag" do
          put topic_url(topic), params: { topic: topic_params }

          expect(response).to redirect_to(topics_url)
          expect(topic.reload.current_tags).to be_empty
          expect(Tag.find_by(name: tag.name)).to be_nil
        end
      end

      context "when the tag is still used on another topic" do
        let!(:topic_2) { create(:topic, provider: provider, language: language) }
        let(:topic_params) {  { tag_list: [ "" ] } }

        before do
          topic_2.set_tag_list_on(topic.language.code.to_sym, tag.name)
          topic_2.save
        end

        it "removes the tag from the topic but does not destroy the tag" do
          put topic_url(topic), params: { topic: topic_params }
          expect(response).to redirect_to(topics_url)
          expect(topic.reload.current_tags).to be_empty
          expect(Tag.find_by(name: tag.name)).to be_present
        end
      end
    end

    context "when removing a tag whose cognate remains associated to the Topic" do
      let!(:tag) { create(:tag, name: "tag") }
      let!(:cognate) { create(:tag, name: "cognate") }
      let(:topic_params) {  { tag_list: [ "cognate" ] } }

      before do
        tag.cognates << cognate
        topic.set_tag_list_on(topic.language.code.to_sym, "tag,cognate")
        topic.save
      end

      it "removes the tag and the cognate" do
        put topic_url(topic), params: { topic: topic_params }

        expect(response).to redirect_to(topics_url)
        expect(topic.reload.current_tags).to eq([])
        expect(Tag.find_by(name: "tag")).to be_nil
        expect(Tag.find_by(name: "cognate")).to be_nil
      end
    end

    context "when topic has documents" do
      let(:topic) { create(:topic, :with_documents) }
      let(:blob) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "dummy.pdf")),
          filename: "dummy.pdf",
          content_type: "application/pdf",
        )
      end
      let(:topic_params) do
        { title: "new topic with documents", document_signed_ids: [ blob.signed_id ] }
      end

      before do
        allow(DocumentsSyncJob).to receive(:perform_later)
      end

      context "when new documents is added" do
        it "runs sync job for documents added and removed" do
          put topic_url(topic), params: { topic: topic_params }

          expect(response).to redirect_to(topics_url)
          topic.reload
          expect(topic.documents.count).to eq(2)
          expect(topic.documents.last.filename.to_s).to eq("dummy.pdf")
          expect(DocumentsSyncJob).to have_received(:perform_later).with(hash_including(action: "delete"))
          expect(DocumentsSyncJob).to have_received(:perform_later).with(
            topic_id: topic.id,
            document_id: topic.documents.last.id,
            action: "update",
          )
        end
      end
    end
  end
end
