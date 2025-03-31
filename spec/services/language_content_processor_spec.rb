require "rails_helper"

RSpec.describe LanguageContentProcessor do
  subject { described_class.new }

  let(:language) { create(:language) }
  let(:provider) { create(:provider) }

  before do
    create(:topic, language:, provider:)
  end

  it "content for every language" do
    result = subject.perform
    expect(result.size).to eq(Language.count)
    expect(result[language.id]).to be_a(Hash)
    expect(result[language.id].keys).to include(:title_and_tags, :tags, :all_providers, provider.name)
  end
end
