# This class is responsible for managing file workers for document synchronization actions.
# It initializes with the action type, document, and topic, and provides methods to create file workers.
#
# The file workers handle the actual file operations such as sending, copying, and deleting files
# in the Azure storage share.

class FileManager
  def initialize(share:, action:, document:, topic:)
    @share = share
    @action = action
    @document = document
    @topic = topic
  end

  def workers
    file_routes.map do |file_route|
      FileWorker.new(
        share:,
        path: current_path(file_route),
        file: file_content,
        name: file_name,
        new_path: new_path(file_route),
      )
    end
  end

  private

  attr_reader :share, :action, :document, :topic

  def file_routes
    return video_file_routes if video_document?

    regular_file_routes
  end

  def video_file_routes
    [
      {
        path: "#{language.file_storage_prefix}CMES-v2/assets/VideoContent",
        archive: "#{language.file_storage_prefix}CMES-v2_Archive",
      },
    ]
  end

  def regular_file_routes
    [
      {
        path: "#{language.file_storage_prefix}CMES-Pi/assets/Content",
        archive: "#{language.file_storage_prefix}CMES-Pi_Archive",
      },
      {
        path: "#{language.file_storage_prefix}CMES-v2/assets/Content",
        archive: "#{language.file_storage_prefix}CMES-v2_Archive",
      },
    ]
  end

  def current_path(file_route)
    return file_route[:path] if !action.include?("archive")

    topic.archived? ? file_route[:path] : file_route[:archive]
  end

  def new_path(file_route)
    return file_route[:archive] if action == "archive"
    return file_route[:path] if action == "unarchive"

    nil
  end

  def video_document?
    document.content_type == "video/mp4"
  end

  def file_content
    @file_content ||= document.download
  end

  # naming convention described here: https://github.com/rubyforgood/skillrx/issues/305
  # [topic.id]_[provider.provider_name_for_file]_[topic.published_at_year]_[topic.published_at_month][document.filename.parameterize].[extension]
  def file_name
    provider = topic.provider
    @file_name ||= [].tap do |parts|
      parts << topic.id
      parts << provider.filename
      parts << topic.published_at_year
      parts << format("%02d", topic.published_at_month)
      parts << document.filename
    end.join("_")
  end

  def language
    @language ||= topic.language
  end
end
