require "rails_helper"

RSpec.describe Topics::Mutator do
  subject { described_class.new(topic:, params:, document_signed_ids:) }

  let(:topic) { Topic.new(params) }
  let(:topic_shadow) { instance_double(Topic, shadow_copy: true, id: 123, documents: topic.documents) }
  let(:language) { create(:language) }
  let(:provider) { create(:provider) }
  let(:params) { attributes_for(:topic).merge(language_id: language.id, provider_id: provider.id) }
  let(:document_signed_ids) { [] }

  before do
    allow(DocumentsSyncJob).to receive(:perform_later)
    allow(subject).to receive(:topic_shadow_with_attachments).and_return(topic_shadow)
  end

  describe "#create" do
    let(:document_signed_ids) do
      [
        ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("dummy content"),
          filename: "dummy.pdf",
          content_type: "application/pdf",
        ).signed_id,
      ]
    end

    it "creates a new topic and runs the sync job for documents" do
      status, created_topic = subject.create

      expect(status).to eq(:ok)
      expect(created_topic).to be_persisted
      expect(created_topic.state).to eq("active")
      expect(DocumentsSyncJob).to have_received(:perform_later).with(
        topic_id: created_topic.id,
        document_id: created_topic.documents.first.id,
        action: "update",
      )
    end
  end

  describe "#update" do
    let(:topic) { create(:topic, :with_documents, description: "topic details") }

    it "updates the topic and runs the sync job for documents" do
      expect(DocumentsSyncJob).to receive(:perform_later).with(
        topic_id: topic_shadow.id,
        document_id: topic_shadow.documents.first.id,
        action: "delete",
      )
      expect(DocumentsSyncJob).to receive(:perform_later).with(
        topic_id: topic.id,
        document_id: topic.documents.first.id,
        action: "update",
      )

      status, updated_topic = subject.update

      expect(status).to eq(:ok)
      expect(updated_topic).to be_persisted
      expect(updated_topic.description).to eq("many topic details")
    end
  end

  describe "#archive" do
    let(:topic) { create(:topic, :with_documents) }

    it "archives the topic and runs the sync job for documents" do
      expect(DocumentsSyncJob).to receive(:perform_later).with(
        topic_id: topic.id,
        document_id: topic.documents.first.id,
        action: "archive",
      )

      status, archived_topic = subject.archive

      expect(status).to eq(:ok)
      expect(archived_topic).to be_persisted
      expect(archived_topic.state).to eq("archived")
    end
  end

  describe "#destroy" do
    let(:topic) { create(:topic, :with_documents) }

    it "deletes the topic and runs the sync job for documents" do
      expect(DocumentsSyncJob).to receive(:perform_later).with(
        topic_id: topic_shadow.id,
        document_id: topic_shadow.documents.first.id,
        action: "delete",
      )

      status, _ = subject.destroy

      expect(status).to eq(:ok)
      expect { topic.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
