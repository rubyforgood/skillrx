class UploadsController < ApplicationController
  def create
    if empty_documents.any?
      return render json: { result: "error", message: empty_documents_message }, status: :unprocessable_content
    end

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
    return head :unprocessable_content unless blob

    blob.purge if blob.attachments.empty?

    render json: { result: "success" }
  end

  private

  def document_params
    documents.map do |document|
      {
        io: document,
        filename: derived_filename(document),
        content_type: document.content_type,
      }
    end
  end

  def documents
    @documents ||= params.require(:documents)
  end

  def empty_documents
    @empty_documents ||= documents.select { |document| document.size.zero? }
  end

  def empty_documents_message
    names = empty_documents.map { |document| original_filename(document) }.to_sentence

    "Nothing was uploaded because #{names} #{empty_documents.one? ? "is" : "are"} empty (0 bytes). " \
      "Check the file on your computer and try again."
  end

  def derived_filename(document)
    filename = original_filename(document)

    name = File.basename(filename, ".*")
    ext = File.extname(filename).delete_prefix(".")
    [
      Topic::INTERNAL_FILENAME_PREFIX,
      [ name.parameterize(separator: "_"), ext ].compact.join("."),
    ].join("_")
  end

  def original_filename(document)
    if document.respond_to?(:original_filename)
      document.original_filename
    elsif document.respond_to?(:filename)
      document.filename.to_s
    else
      "unnamed"
    end
  end
end
