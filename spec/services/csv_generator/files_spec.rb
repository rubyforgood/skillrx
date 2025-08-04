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
          csv << "#{document.id},#{topic.id},#{topic.fullname_for_document(document)},#{document.content_type},#{document.byte_size}\n"
        end
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
