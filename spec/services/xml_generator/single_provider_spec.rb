require "rails_helper"

RSpec.describe XmlGenerator::SingleProvider do
  subject { described_class.new(provider) }

  let(:provider) { create(:provider) }

  it "generates the xml" do
    expect(subject.perform).to eq(
      <<~TEXT
        <?xml version="1.0"?>
        <cmes>
          <content_provider name="#{provider.name}"/>
        </cmes>
      TEXT
    )
  end

  context "with topics" do
    let!(:topic) { create(:topic, provider: provider) }

    it "generates the xml" do
      expect(subject.perform).to eq(
        <<~TEXT
          <?xml version="1.0"?>
          <cmes>
            <content_provider name="#{provider.name}">
              <topic_year year="#{topic.created_at.year}">
                <topic_month month="#{topic.created_at.strftime("%m_%B")}">
                  <title name="#{topic.title}">
                    <topic_id>#{topic.id}</topic_id>
                    <counter>0</counter>
                    <topic_volume>#{topic.created_at.year}</topic_volume>
                    <topic_issue>0</topic_issue>
                    <topic_files files="Files"/>
                  </title>
                </topic_month>
              </topic_year>
            </content_provider>
          </cmes>
        TEXT
      )
    end
  end
end
