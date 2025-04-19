require "rails_helper"

RSpec.describe XmlGenerator::AllProviders do
  subject { described_class.new(language) }

  let(:language) { create(:language) }
  let(:provider1) { create(:provider) }
  let(:provider2) { create(:provider) }
  let!(:topic1) { create(:topic, :tagged, language:, provider: provider1) }
  let!(:topic2) { create(:topic, :tagged, language:, provider: provider2) }

  it "generates the xml" do
    expect(subject.perform).to eq(
      <<~TEXT
        <?xml version="1.0"?>
        <cmes>
          <content_provider name="#{provider1.name}">
            <topic_year year="#{topic1.created_at.year}">
              <topic_month month="#{topic1.created_at.strftime("%m_%B")}">
                <title name="#{topic1.title}">
                  <topic_id>#{topic1.id}</topic_id>
                  <topic_files files="Files"/>
                  <topic_tags>#{topic1.current_tags_list.join(", ")}</topic_tags>
                </title>
              </topic_month>
            </topic_year>
          </content_provider>
          <content_provider name="#{provider2.name}">
            <topic_year year="#{topic2.created_at.year}">
              <topic_month month="#{topic2.created_at.strftime("%m_%B")}">
                <title name="#{topic2.title}">
                  <topic_id>#{topic2.id}</topic_id>
                  <topic_files files="Files"/>
                  <topic_tags>#{topic2.current_tags_list.join(", ")}</topic_tags>
                </title>
              </topic_month>
            </topic_year>
          </content_provider>
        </cmes>
      TEXT
    )
  end
end
