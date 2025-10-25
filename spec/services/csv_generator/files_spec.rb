require "rails_helper"

RSpec.describe CsvGenerator::Files do
  subject { described_class.new(language) }

  let(:language) { create(:language) }
  let(:header) { "FileID,TopicID,FileName,FileType,FileSize\n" }

  it "generates empty csv" do
    expect(subject.perform).to eq(header)
  end

  context "when topics with documents exist" do
    let!(:topic) { create(:topic, :with_documents, language:) }
    let(:data) do
      header.tap do |csv|
        topic.documents.each do |document|
          csv << "#{document.id},#{topic.id},test_image.png,#{document.content_type},#{document.byte_size}\n"
        end
      end
    end

    it "generates csv with documents info" do
      expect(subject.perform).to eq(data)
    end

    context "when document filename is prefixed with [skillrx_internal_upload]" do
      let(:data) do
        header.tap do |csv|
          topic.documents.each do |document|
            csv << "#{document.id},#{topic.id},#{topic.id}_#{topic.provider.file_name_prefix.parameterize}_#{topic.published_at_year}_#{topic.published_at_month}_test_image.png,#{document.content_type},#{document.byte_size}\n"
          end
        end
      end

      before do
        topic.documents.first.update(filename: "[skillrx_internal_upload]_test_image.png")
      end

      it "uses custom file name in csv" do
        expect(subject.perform).to eq(data)
      end
    end
  end

  context "when topic exists but archived" do
    let!(:topic) { create(:topic, :with_documents, :archived, language:) }

    it "generates empty csv" do
      expect(subject.perform).to eq(header)
    end
  end

  context "when topic does not belong to language" do
    let(:other_language) { create(:language) }
    let!(:topic) { create(:topic, :with_documents, language: other_language) }

    it "generates empty csv" do
      expect(subject.perform).to eq(header)
    end
  end
end
