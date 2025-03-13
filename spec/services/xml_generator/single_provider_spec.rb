require "rails_helper"

RSpec.describe XmlGenerator::SingleProvider do
  subject { described_class.new(provider) }

  let(:provider) { create(:provider) }

  it "generates the xml" do
    expect(subject.perform).to eq(
      <<~TEXT
        <?xml version="1.0"?>
        <root>
          <provider>
            <name>#{provider.name}</name>
            <type>#{provider.provider_type}</type>
          </provider>
          <topics/>
        </root>
      TEXT
    )
  end

  context "with topics" do
    let!(:topic) { create(:topic, provider: provider) }

    it "generates the xml" do
      expect(subject.perform).to eq(
        <<~TEXT
          <?xml version="1.0"?>
          <root>
            <provider>
              <name>#{provider.name}</name>
              <type>#{provider.provider_type}</type>
            </provider>
            <topics>
              <topic>
                <title>#{topic.title}</title>
                <description>#{topic.description}</description>
                <state>#{topic.state}</state>
                <uid/>
              </topic>
            </topics>
          </root>
        TEXT
      )
    end
  end
end
