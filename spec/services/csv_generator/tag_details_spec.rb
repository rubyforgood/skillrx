require "rails_helper"

RSpec.describe CsvGenerator::TagDetails do
  subject { described_class.new(language) }

  let(:language) { create(:language) }
  let(:header) { "TagID,Tag\n" }

  it "generates empty csv" do
    expect(subject.perform).to eq(header)
  end

  context "when tagged topics exist" do
    let!(:topic) { create(:topic, :tagged, language:) }
    let(:data) do
      header.tap do |csv|
        topic.tags_on(language.code.to_sym).each do |tag|
          csv << "#{tag.id},#{tag.name}\n"
        end
      end
    end

    it "generates csv with tags details" do
      expect(subject.perform).to eq(data)
    end

    context "when second topic with same tags exists" do
      let(:second_topic) { create(:topic, language:) }

      before do
        topic.base_tags.each do |t|
          tag = build(:tag, name: t.name)
          second_topic.tag_list.add([ tag.name ])
          second_topic.save
        end
      end

      it "generates csv with unique tags" do
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
