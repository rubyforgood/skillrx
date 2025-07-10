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
      sync_docs_for_topic_archive if topic.documents.any?
      return [ :ok, topic ]
    end

    [ :error, topic.errors.full_messages ]
  end

  def unarchive
    if @topic.active!
      sync_docs_for_topic_archive if topic.documents.any?
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
    topic.valid?
    return [ :error,  topic.errors.full_messages ] if topic.errors.any?

    docs_to_delete = outdated_documents
    ActiveRecord::Base.transaction do
      topic.save_with_tags(params)
      attach_files(document_signed_ids)
      shadow_delete_documents(docs_to_delete) if updating_documents?
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
    topic.documents_attachments.each do |doc|
      next unless doc.previous_changes.present?

      DocumentsSyncJob.perform_later(
        topic_id: topic.id,
        document_id: doc.id,
        action: "update",
      )
    end
  end

  def sync_docs_for_topic_archive
    return unless topic.saved_change_to_state?

    sync_archieve if topic.state_previously_was == "active" && topic.state == "archived"
    sync_unarchieve if topic.state_previously_was == "archived" && topic.state == "active"
  end

  def sync_archieve
    topic.documents_attachments.each do |doc|
      DocumentsSyncJob.perform_later(
        topic_id: topic.id,
        document_id: doc.id,
        action: "archive",
      )
    end
  end

  def sync_unarchieve
    topic.documents_attachments.each do |doc|
      DocumentsSyncJob.perform_later(
        topic_id: topic.id,
        document_id: doc.id,
        action: "unarchive",
      )
    end
  end

  def sync_docs_for_topic_deletion
    shadow_delete_documents(topic.documents_attachments)
  end

  def shadow_delete_documents(docs_to_delete)
    return if docs_to_delete.empty?

    topic_shadow = topic_shadow_with_attachments(docs_to_delete)
    topic_shadow.documents.each do |doc|
      DocumentsSyncJob.perform_later(
        topic_id: topic_shadow.id,
        document_id: doc.id,
        action: "delete",
      )
    end
  end

  def topic_shadow_with_attachments(docs_to_delete)
    topic.dup.tap do |shadow|
      shadow.shadow_copy = true
      docs_to_delete.each do |doc|
        shadow.documents.attach(doc.signed_id)
      end
      shadow.save!
    end
  end

  def outdated_documents
    return [] if document_signed_ids.nil?

    topic.documents_attachments.reject do |doc|
      document_signed_ids&.include?(doc.signed_id)
    end
  end

  def updating_documents?
    topic.persisted? && topic.documents.any? && !document_signed_ids.nil?
  end
end
