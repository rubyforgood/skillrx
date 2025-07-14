class DocumentsSyncJob < ApplicationJob
  def perform(topic_id:, document_id:, action:, share: ENV["AZURE_STORAGE_SHARE_NAME"])
    return if ENV["AZURE_MEDIA_FILES_SYNC_DISABLED"].present?

    @share = share
    @action = action
    @topic = Topic.unscoped.find(topic_id)
    @document = topic.documents.find(document_id)

    process_action
  end

  private

  def process_action
    case action
    when "update"
      file_workers.each(&:send)
    when "archive"
      file_workers.each_with_index do |worker, i|
        worker.copy(file_routes[i][:archive])
        worker.delete
      end
    when "unarchive"
      file_workers.each_with_index do |worker, i|
        worker.copy(file_routes[i][:path])
        worker.delete
      end
    when "delete"
      file_workers.each(&:delete)
    else
      raise ArgumentError, "Unknown action: #{action}"
    end
  end

  def file_workers
    @file_workers ||= file_manager.workers
  end

  def file_manager
    @file_manager ||= FileManager.new(share:, action:, document:, topic:)
  end

  attr_reader :topic, :share, :document, :action
end
