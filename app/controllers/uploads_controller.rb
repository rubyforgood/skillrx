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
        filename: derived_filename(document),
        content_type: document.content_type,
      }
    end
  end

  def derived_filename(document)
    filename =
      if document.respond_to?(:original_filename)
        document.original_filename
      elsif document.respond_to?(:filename)
        document.filename.to_s
      else
        "unnamed"
      end

    name = File.basename(filename, ".*")
    ext = File.extname(filename).delete_prefix(".")
    [
      Topic::INTERNAL_FILENAME_PREFIX,
      [ name.parameterize(separator: "_"), ext ].compact.join("."),
    ].join("_")
  end
end
