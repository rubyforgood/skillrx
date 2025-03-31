class UploadsController < ApplicationController
  def create
    blobs = document_params.map do |document|
        ActiveStorage::Blob.create_and_upload!(**document)
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

  private

  def document_params
    params.require(:documents).map do |document|
      {
        io: document,
        filename: document.original_filename,
        content_type: document.content_type,
      }
    end
  end
end
