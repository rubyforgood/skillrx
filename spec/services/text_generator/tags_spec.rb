require "rails_helper"

RSpec.describe TextGenerator::Tags do
  subject { described_class.new(language) }

  let(:language) { create(:language) }

  it "generates the text" do
    expect(subject.perform).to eq("")
  end

  context "with tagged topics" do
    let(:language) { create(:language, :tagged) }

    it "generates the text with tags for language" do
      expect(subject.perform).to eq(language.tags.join("\n"))
    end
  end
end
