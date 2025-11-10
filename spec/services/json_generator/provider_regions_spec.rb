require "rails_helper"

RSpec.describe JsonGenerator::ProviderRegions do
  subject { described_class.new(language) }

  let(:language) { create(:language) }

  it "generates empty json" do
    expect(subject.perform).to eq("[]")
  end

  context "when providers exist" do
    let!(:provider) { create(:provider) }

    before do
      create(:topic, provider:, language:)
    end

    it "generates json with provider data" do
      expect(subject.perform).to eq([
        {
          name: provider.name,
          prefix: provider.file_name_prefix,
          regions: provider.regions,
        },
      ].to_json)
    end
  end

  context "when provider does not belong to language" do
    let(:other_language) { create(:language) }
    let!(:provider) { create(:provider) }

    before do
      create(:topic, provider:, language: other_language)
    end

    it "generates empty json" do
      expect(subject.perform).to eq("[]")
    end
  end
end
