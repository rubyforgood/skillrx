require "rails_helper"

RSpec.describe TextGenerator::TitleAndTags do
  subject { described_class.new(language) }

  let(:language) { create(:language) }
  let!(:topic) { create(:topic, language: language) }

  it "generates the text" do
    expect(subject.perform).to eq(topic.title)
  end

  context "with tagged topics" do
    let!(:topic) { create(:topic, :tagged, language: language) }

    it "generates the text with title and tags for topics" do
      expect(subject.perform).to eq("#{topic.title},#{topic.current_tags_list.join(",")}")
    end
  end
end
