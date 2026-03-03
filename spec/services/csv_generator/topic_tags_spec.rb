require "rails_helper"

RSpec.describe CsvGenerator::TopicTags do
  subject { described_class.new(source, **args) }

  let(:language) { create(:language) }
  let(:source) { language }
  let(:args) { {} }
  let(:header) { "TopicID,TagID\n" }

  it "generates empty csv" do
    expect(subject.perform).to eq(header)
  end

  context "when tagged topics exist" do
    let!(:topic) { create(:topic, :tagged, language:) }
    let(:data) do
      header.tap do |csv|
        topic.tags_on(language.code.to_sym).each do |tag|
          csv << "#{topic.id},#{tag.id}\n"
        end
      end
    end

    it "generates csv with topic tag info" do
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
    let!(:topic) { create(:topic, :tagged, :archived, language:) }

    it "generates empty csv" do
      expect(subject.perform).to eq(header)
    end
  end

  context "when topic does not belong to language" do
    let(:other_language) { create(:language) }
    let!(:topic) { create(:topic, :tagged, language: other_language) }

    it "generates empty csv" do
      expect(subject.perform).to eq(header)
    end
  end
end
