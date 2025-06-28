class DocumentsSyncJob < ApplicationJob
  attr_reader :topic, :share, :document

  def perform(topic_id, document_id, action, share = ENV["AZURE_STORAGE_SHARE_NAME"])
    @share = share
    @topic = Topic.find(topic_id)
    @document = topic.documents.find(document_id)

    case action
    when "create", "update"
      file_worker.send
    when "archive"
      file_worker.copy(archive_path)
      file_worker.delete
    when "delete"
      file_worker.delete
    else
      raise ArgumentError, "Unknown action: #{action}"
    end
  end

  private

  def name
    document.filename.to_s
  end

  def path
    "#{language.file_storage_prefix}CMES-Pi/assets/content"
  end

  def archive_path
    "#{language.file_storage_prefix}CMES-Pi_Archive"
  end

  def file
    document.download
  end

  def file_worker
    @file_worker ||= FileWorker.new(share: share, name: name, path: path, file: file)
  end

  def language
    @language ||= topic.language
  end

  def client
    @client ||= AzureFileShares.client
  end
end
