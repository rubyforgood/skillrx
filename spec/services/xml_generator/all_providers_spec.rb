require "rails_helper"

RSpec.describe XmlGenerator::AllProviders do
  subject { described_class.new(language) }

  let(:language) { create(:language) }
  let(:provider1) { create(:provider) }
  let(:provider2) { create(:provider) }
  let!(:topic1) { create(:topic, :tagged, language:, provider: provider1) }
  let!(:topic2) { create(:topic, :with_documents, :tagged, language:, provider: provider2) }
  let(:tag_topic1) { create(:tag, name: "flu") }
  let(:tag_topic2) { create(:tag, name: "diabetes") }

  before do
    topic1.set_tag_list_on(topic1.language_code, tag_topic1.name)
    topic1.save
    topic2.set_tag_list_on(topic2.language_code, tag_topic1.name)
    topic2.save
  end

  it "generates the xml" do
    xml = subject.perform
    doc = Nokogiri::XML(xml)

    [ provider1, provider2 ].each do |prov|
      pnode = doc.at_xpath("//cmes/content_provider[@name='#{prov.name}']")
      expect(pnode).to be_present
    end

    [ [ provider1, topic1 ], [ provider2, topic2 ] ].each do |prov, topic|
      pnode = doc.at_xpath("//cmes/content_provider[@name='#{prov.name}']")
      year = topic.published_at.year
      ynode = pnode.at_xpath("./topic_year[@year='#{year}']")
      expect(ynode).to be_present

      month_label = topic.published_at.strftime("%m_%B")
      mnode = ynode.at_xpath("./topic_month[@month='#{month_label}']")
      expect(mnode).to be_present

      tnode = mnode.at_xpath("./title[@name='#{topic.title}']")
      expect(tnode).to be_present

      expect(tnode.at_xpath("./topic_id").text).to eq(topic.id.to_s)
      expect(tnode.at_xpath("./counter").text).to eq("0")
      expect(tnode.at_xpath("./topic_volume").text).to eq(topic.published_at.year.to_s)
      expect(tnode.at_xpath("./topic_issue").text).to eq(topic.published_at.month.to_s)

      files = tnode.at_xpath("./topic_files[@files='Files']")
      expect(files).to be_present
      if topic.documents.attached? && topic.documents.reject { |d| d.content_type == "video/mp4" }.any?
        first_file = files.element_children.first
        expect(first_file).to be_present
        expect(first_file.text).to be_present
  expect(first_file["file_size"]).to be_present
      else
        expect(files.element_children).to be_empty
      end

      author1 = tnode.at_xpath("./topic_author/topic_author_1")
      expect(author1.text).to eq(" ")

      expect(tnode.at_xpath("./topic_tags").text).to eq(topic.current_tags_list.join(", "))
    end
  end

  context "when a provider has topics in multiple languages" do
    subject { described_class.new(Language.find_by(name: "en")) }

    before do
      create(:language, name: "es")

      XmlTestDataBuilder.xml_scenario
        .for_language(name: "en")
        .for_provider(name: "Health Corp")
        .with_topic(
          title: "English Topic",
          published_at: 2.weeks.ago
        )
        .build!

      XmlTestDataBuilder.xml_scenario
        .for_language(name: "es")
        .for_provider(name: "Health Corp") # Same provider
        .with_topic(
          title: "Spanish Topic",
          published_at: 3.weeks.ago
        )
        .build!
    end

    it "incorrectly includes topics from other languages in its output" do
      doc = Nokogiri::XML(subject.perform)

      english_topic_node = doc.at_xpath("//title[@name='English Topic']")
      spanish_topic_node = doc.at_xpath("//title[@name='Spanish Topic']")

      # It correctly finds the English topic.
      expect(english_topic_node).not_to be_nil

      # It incorrectly finds the Spanish topic, demonstrating the bug.
      expect(spanish_topic_node).not_to be_nil
    end
  end
end
