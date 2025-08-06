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
    blob = ActiveStorage::Blob.find_signed(params[:id])
    return head :unprocessable_entity unless blob

    blob.purge if blob.attachments.empty?

    render json: { result: "success" }
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
