require "rails_helper"

RSpec.describe TextGenerator::TitleAndTags do
  subject { described_class.new(language) }

  let(:language) { create(:language) }
  let!(:topic) { create(:topic, language:) }

  it "generates text with title only" do
    expect(subject.perform).to eq(topic.title)
  end

  context "when tagged topics exist" do
    let!(:topic) { create(:topic, :tagged, language:) }

    it "generates text with title and tags for topics" do
      expect(subject.perform).to eq(([ topic.title ] + topic.tag_list).join("\n"))
    end
  end

  context "when topic does not belong to language" do
    let(:other_language) { create(:language) }
    let!(:topic) { create(:topic, :tagged, language: other_language) }

    it "generates empty text" do
      expect(subject.perform).to be_empty
    end
  end
end
