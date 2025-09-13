require "rails_helper"

RSpec.describe Topics::Mutator do
  subject { described_class.new(topic:, params:, document_signed_ids:) }

  let(:topic) { Topic.new(params) }
  let(:topic_shadow) { Topic.unscoped.where(shadow_copy: true).last }
  let(:language) { create(:language) }
  let(:provider) { create(:provider) }
  let(:document_signed_ids) { nil }
  let(:document_ids) { [] }
  let(:params) do
    attributes_for(:topic).merge(
      language_id: language.id,
      provider_id: provider.id,
      documents: document_ids,
    )
  end

  before { allow(DocumentsSyncJob).to receive(:perform_later) }

  describe "#create" do
    let(:document_signed_ids) do
      [
        ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("dummy content"),
          filename: "rename_dummy.pdf",
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
      expect(created_topic.reload.documents.first.blob.filename.to_s).to eq("rename_dummy.pdf")
    end
  end

  describe "#update" do
    let(:topic) { create(:topic, :with_documents, description: "topic details") }
    let(:document_signed_ids) do
      [
        ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("dummy content"),
          filename: "dummy.pdf",
          content_type: "application/pdf",
        ).signed_id,
      ]
    end

    it "updates the topic and runs the sync job for documents" do
      status, updated_topic = subject.update

      expect(status).to eq(:ok)
      expect(updated_topic).to be_persisted
      expect(updated_topic.description).to eq("many topic details")
      expect(DocumentsSyncJob).to have_received(:perform_later).with(
        topic_id: topic_shadow.id,
        document_id: topic_shadow.documents.first.id,
        action: "delete",
      )
      expect(DocumentsSyncJob).to have_received(:perform_later).with(
        topic_id: topic.id,
        document_id: topic.documents.first.id,
        action: "update",
      )
    end

    context "when existing document is not removed" do
      let(:document_ids) { [ topic.documents.first.signed_id ] }
      let(:document_signed_ids) { [] }

      it "updates the topic but does not runs the sync job for documents" do
        expect(DocumentsSyncJob).not_to receive(:perform_later)

        status, updated_topic = subject.update

        expect(status).to eq(:ok)
        expect(updated_topic).to be_persisted
        expect(updated_topic.description).to eq("many topic details")
      end

      it "does not rename existing documents" do
        expect { subject.update }.not_to change { topic.reload.documents.first.blob.filename.to_s }.from("test_image.png")
      end
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

  describe "#unarchive" do
    let(:topic) { create(:topic, :with_documents, state: "archived") }

    it "unarchive the topics" do
      expect(DocumentsSyncJob).to receive(:perform_later).with(
        topic_id: topic.id,
        document_id: topic.documents.first.id,
        action: "unarchive",
      )

      status, unarchived_topic = subject.unarchive

      expect(status).to eq(:ok)
      expect(unarchived_topic).to be_persisted
      expect(unarchived_topic.state).to eq("active")
    end
  end

  describe "#destroy" do
    let(:topic) { create(:topic, :with_documents) }

    it "deletes the topic and runs the sync job for documents" do
      status, _ = subject.destroy

      expect(status).to eq(:ok)
      expect { topic.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect(DocumentsSyncJob).to have_received(:perform_later).with(
        topic_id: topic_shadow.id,
        document_id: topic_shadow.documents.first.id,
        action: "delete",
      )
    end
  end
end
