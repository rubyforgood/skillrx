require "rails_helper"

RSpec.describe CsvGenerator::TopicAuthors do
  subject { described_class.new(source, **args) }

  let(:language) { create(:language) }
  let(:source) { language }
  let(:args) { {} }
  let(:header) { "TopicID,AuthorID\n" }

  it "generates empty csv" do
    expect(subject.perform).to eq(header)
  end

  context "when topics exist" do
    let!(:topic) { create(:topic, language:) }
    let(:data) do
      header.tap do |csv|
        csv << "#{topic.id},0\n"
      end
    end

    it "generates csv with topics info" do
      expect(subject.perform).to eq(data)
    end

    context "when generated for provider" do
      let(:source) { topic.provider }
      let(:args) { { language: } }

      it "generates csv with documents info" do
        expect(subject.perform).to eq(data)
      end
    end
  end

  context "when topic exists but archived" do
    let!(:topic) { create(:topic, :archived, language:) }

    it "generates empty csv" do
      expect(subject.perform).to eq(header)
    end
  end

  context "when topic does not belong to language" do
    let(:other_language) { create(:language) }
    let!(:topic) { create(:topic, language: other_language) }

    it "generates empty csv" do
      expect(subject.perform).to eq(header)
    end
  end
end
