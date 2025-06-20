require "rails_helper"

RSpec.describe TopicsHelper, type: :helper do
  describe "#card_preview_media" do
    let(:topic) { create(:topic, :with_documents) }

    before(:each) do
      ActiveStorage::Current.url_options = { host: "localhost:3000" }
    end

    context "when file is an image" do
      it "renders an image tag" do
        result = helper.card_preview_media(topic.documents.first)
        expect(result).to include("img-fluid")
        expect(result).to include("src=")
      end
    end

    context "when file is a PDF" do
      before do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("PDF content"),
          filename: "test.pdf",
          content_type: "application/pdf"
        )
        topic.documents.attach(blob)
      end

      it "renders a PDF viewer" do
        result = helper.card_preview_media(topic.documents.last)
        expect(result).to include("application/pdf")
        expect(result).to include("object")
      end
    end

    context "when file is a video" do
      before do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("Video content"),
          filename: "test_video.mp4",
          content_type: "video/mp4"
        )
        topic.documents.attach(blob)
      end

      it "renders a video tag" do
        result = helper.card_preview_media(topic.documents.last)
        expect(result).to include("video")
      end
    end

    context "when file is of an unknown type" do
      before do
        blob = ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("Text content"),
          filename: "test.txt",
          content_type: "text/plain"
        )
        topic.documents.attach(blob)
      end

      it "renders a download link" do
        result = helper.card_preview_media(topic.documents.last)
        expect(result).to include("href=")
        expect(result).to include("test.txt")
      end
    end
  end
end
