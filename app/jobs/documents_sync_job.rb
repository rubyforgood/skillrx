class DocumentsSyncJob < ApplicationJob
  def perform(topic_id:, document_id:, action:, share: ENV["AZURE_STORAGE_SHARE_NAME"])
    return if ENV["AZURE_MEDIA_FILES_SYNC_DISABLED"].present?

    @share = share
    @action = action
    @topic = Topic.unscoped.find(topic_id)
    @document = topic.documents.find(document_id)

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

  private

  def file_workers
    @file_workes ||= file_routes.map do |file_route|
      path = if action.include?("archive")
        topic.archived? ? file_route[:path] : file_route[:archive]
      else
        file_route[:path]
      end

      FileWorker.new(
        share:,
        path:,
        file: file_content,
        name: file_name,
      )
    end
  end

  def file_routes
    [
      {
        path: "#{language.file_storage_prefix}CMES-Pi/assets/content",
        archive: "#{language.file_storage_prefix}CMES-Pi_Archive",
      },
      {
        path: "#{language.file_storage_prefix}SP_CMES-Pi/assets/content",
        archive: "#{language.file_storage_prefix}SP_CMES-Pi_Archive",
      },
    ]
  end

  def language
    @language ||= topic.language
  end

  def client
    @client ||= AzureFileShares.client
  end

  def file_content
    @file_content ||= document.download
  end

  def file_name
    @file_name ||= document.filename.to_s
  end

  attr_reader :topic, :share, :document, :action
end
