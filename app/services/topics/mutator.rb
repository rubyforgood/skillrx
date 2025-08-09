class Topics::Mutator
  def initialize(topic:, params: nil, document_signed_ids: nil)
    @topic = topic
    @params = params
    @document_signed_ids = document_signed_ids || []
    @document_ids = extract_document_ids
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

  attr_reader :topic, :params, :document_signed_ids, :document_ids

  def mutate
    topic.valid?
    return [ :error,  topic.errors.full_messages ] if topic.errors.any?

    docs_to_delete = rejected_documents
    ActiveRecord::Base.transaction do
      topic.save_with_tags(params)
      attach_files(document_signed_ids)
      shadow_delete_documents(docs_to_delete)
      rename_files(document_signed_ids)
      # document_signed_ids.any? means that some new documents were attached and we need to sync them
      sync_docs_for_topic_updates if document_signed_ids.any?
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

  def rename_files(signed_ids)
    signed_ids.each do |signed_id|
      document = topic.documents.find { |doc| doc.blob.signed_id == signed_id }
      next unless document && need_rename?(document)

      new_filename = topic.custom_file_name(document)
      return if document.filename == new_filename

      rename_document(document, new_filename)
      document.purge
    end
  end

  def need_rename?(document)
    document.blob.filename.to_s.start_with?("rename_")
  end

  def rename_document(document, new_filename)
    file_io = StringIO.new(document.download)
    topic.documents.attach(
      io: file_io,
      filename: new_filename,
      content_type: document.content_type
    )
  end

  def sync_docs_for_topic_updates
    topic.documents_attachments.reload
    topic.documents_attachments.each do |doc|
      DocumentsSyncJob.perform_later(
        topic_id: topic.id,
        document_id: doc.id,
        action: "update",
      )
    end
  end

  def sync_docs_for_topic_archive
    return unless topic.saved_change_to_state?

    sync_archive if topic.state_previously_was == "active" && topic.state == "archived"
    sync_unarchive if topic.state_previously_was == "archived" && topic.state == "active"
  end

  def sync_archive
    topic.documents_attachments.each do |doc|
      DocumentsSyncJob.perform_later(
        topic_id: topic.id,
        document_id: doc.id,
        action: "archive",
      )
    end
  end

  def sync_unarchive
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
    topic_shadow.documents_attachments.each do |doc|
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
      shadow.document_prefix = topic.id
      docs_to_delete.each do |doc|
        shadow.documents.attach(doc.signed_id)
      end
      shadow.save!
    end
  end

  # We mark documents for deletion if they are not in the list of persisted documents or added documents
  def rejected_documents
    maintained_document_ids = document_signed_ids + document_ids

    topic.documents_attachments.reject do |doc|
      maintained_document_ids&.include?(doc.signed_id)
    end
  end

  def extract_document_ids
    documents = params && params[:documents] || []
    documents.map { |doc| doc.is_a?(String) ? doc : doc.signed_id }
  end
end
