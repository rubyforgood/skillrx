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
    let!(:topic) { create(:topic, :with_documents, provider:) }
    let(:tag_1) { create(:tag, name: "iddm") }
    let(:tag_2) { create(:tag, name: "diabetes") }
    let(:document) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join("spec", "fixtures", "files", "video_file_example.mp4")),
        filename: "video_file.mp4",
        content_type: "video/mp4",
      )
    end

    before do
      topic.set_tag_list_on(topic.language.code.to_sym, "#{tag_1.name},#{tag_2.name}")
      topic.save
      topic.documents.attach(document.signed_id) # we need only to attach video file to topic, saving here is redundant
    end

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
                    <topic_files files="Files">
                      <file_name_1 file_size="494323">test_image.png</file_name_1>
                    </topic_files>
                    <topic_tags>#{topic.current_tags_list.join(", ")}</topic_tags>
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
