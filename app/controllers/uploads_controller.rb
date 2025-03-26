class UploadsController < ApplicationController
  def create
    documents = params.require(:documents)
    topic_id = params[:topic_id]
    blobs = []

    documents.each do |document|
      blob =
        ActiveStorage::Blob.create_and_upload!(
          io: document,
          filename: document.original_filename,
          content_type: document.content_type,
        )

      if topic_id.present?
        topic = Topic.find(topic_id)
        topic.documents.attach(blob.signed_id)
      end

      blobs.push(blob)
    end

    html_content =
      render_to_string(
        partial: "topics/document_list",
        locals: {
          blobs: blobs,
          hidden_input: true,
        },
      )

    render json: { result: "success", html: html_content }
  end

  def destroy
    # Fetch the blob using the signed id
    blob = ActiveStorage::Blob.find_signed(params[:id])
    if blob
      if blob.attachments.any?
        # the blob is attached to topic record
        blob.attachments.each { |attachment| attachment.purge }
      else
        blob.purge
      end

      render json: { result: "success" }
    else
      # blob not found
      head :unprocessable_entity
    end
  end
end
