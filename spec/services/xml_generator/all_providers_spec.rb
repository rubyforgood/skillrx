require "rails_helper"

RSpec.describe XmlGenerator::AllProviders do
  subject { described_class.new([ provider1, provider2 ]) }

  let(:provider1) { create(:provider) }
  let(:provider2) { create(:provider) }

  it "generates the xml" do
    expect(subject.perform).to eq(
      <<~TEXT
        <?xml version="1.0"?>
        <cmes>
          <content_provider name="#{provider1.name}"/>
          <content_provider name="#{provider2.name}"/>
        </cmes>
      TEXT
    )
  end
end
