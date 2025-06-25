class DocumentSyncsJob < ApplicationJob
  attr_reader :topic

  def perform(topic_id, document_id, action, share = ENV["AZURE_STORAGE_SHARE_NAME"])
    @topic = Topic.find(topic_id)

    FileSender.new(share:, name:, path:, file:).perform
  end

  private

  def document
    @document ||= topic.documents.find(document_id)
  end

  def name
    document.filename.to_s
  end

  def path
    "topics/#{topic.id}/documents/#{document.id}/#{document.filename}"
  end

  def file
    document.download
  end
end
