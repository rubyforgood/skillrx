class Topics::Mutator
  def initialize(topic:, params: nil, document_signed_ids: nil)
    @topic = topic
    @params = params
    @document_signed_ids = document_signed_ids
  end

  def create
    mutate
  end

  def update
    mutate
  end

  def archive
    if @topic.archived!
      sync_docs_for_topic_updates if topic.documents.any?
      return [ :ok, topic ]
    end

    [ :error, topic.errors.full_messages ]
  end

  def destroy
    # If topic deletion fails for some reason, documents deletion still will happen
    # This case is unlikely, and only admins can delete topics
    sync_docs_for_topic_deletion if topic.documents.any?
    return [ :ok, topic ] if topic.destroy

    [ :error, topic.errors.full_messages ]
  end

  private

  attr_reader :topic, :params, :document_signed_ids

  def mutate
    @topic.valid?
    return [ :error,  topic.errors.full_messages ] if topic.errors.any?

    ActiveRecord::Base.transaction do
      topic.save_with_tags(params)
      attach_files(document_signed_ids)
      sync_docs_for_topic_updates if topic.documents.any?
      [ :ok, topic ]
    rescue ActiveRecord::RecordInvalid => e
      [ :error, e.record.errors.full_messages ]
    end
  end

  def attach_files(signed_ids)
    return if signed_ids.blank?

    signed_ids.each do |signed_id|
      topic.documents.attach(signed_id)
    end
  end

  def sync_docs_for_topic_updates
    if topic.saved_change_to_state? && topic.state_previously_was == "active" && topic.state == "archived"
      return sync_archieve
    end

    sync_update
  end

  def sync_update
    topic.documents_attachments.each do |doc|
      next unless doc.previous_changes.present?

      DocumentsSyncJob.perform_later(
        topic_id: topic.id,
        document_id: doc.id,
        action: "update",
        # action: doc.previous_changes.keys.include?("blob_id") ? "update" : "create"
      )
    end
  end

  def sync_archieve
    topic.documents_attachments.each do |doc|
      DocumentsSyncJob.perform_later(topic_id: topic.id, document_id: doc.id, action: "archive")
    end
  end

  def sync_docs_for_topic_deletion
    topic.documents_attachments.each do |doc|
      DocumentsSyncJob.perform_later(topic_id: topic.id, document_id: doc.id, action: "delete")
    end
  end
end
