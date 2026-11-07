require "rails_helper"

describe "Uploads", type: :request do
  describe "POST /uploads" do
    let(:user) { create(:user) }
    let(:document_params) do
      [
        Rack::Test::UploadedFile.new(
          Rails.root.join("spec", "fixtures", "files", "dummy.pdf"),
          "application/pdf",
          original_filename: "dummy.pdf"
        ),
      ]
    end

    before { sign_in(user) }

    it "uploads a document" do
      post uploads_url, params: { documents: document_params }

      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to include("result" => "success")
      expect(ActiveStorage::Blob.count).to eq(1)
      expect(ActiveStorage::Blob.last.filename.to_s).to eq("[skillrx_internal_upload]_dummy.pdf")
    end

    context "when filename is also requires formatting" do
      let(:document_params) do
        [
          Rack::Test::UploadedFile.new(
            Rails.root.join("spec", "fixtures", "files", "dummy.pdf"),
            "application/pdf",
            original_filename: "who@was#there.pdf"
          ),
        ]
      end

      it "uploads a document and parameterizes its name" do
        post uploads_url, params: { documents: document_params }

        expect(response.status).to eq(200)
        expect(ActiveStorage::Blob.last.filename.to_s).to eq("[skillrx_internal_upload]_who_was_there.pdf")
      end
    end

    context "when one of the files is empty" do
      let(:document_params) do
        [
          Rack::Test::UploadedFile.new(
            Rails.root.join("spec", "fixtures", "files", "dummy.pdf"),
            "application/pdf",
            original_filename: "dummy.pdf"
          ),
          Rack::Test::UploadedFile.new(StringIO.new(""), "application/pdf", original_filename: "empty.pdf"),
        ]
      end

      it "rejects the upload and names the empty file" do
        post uploads_url, params: { documents: document_params }

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)).to include("result" => "error", "message" => /empty\.pdf/)
        expect(ActiveStorage::Blob.count).to eq(0)
      end
    end
  end
end
