require "rails_helper"

RSpec.describe XmlGenerator::SingleProvider do
  subject { described_class.new(provider) }

  let(:provider) { create(:provider) }

  it "generates the xml" do
  xml = subject.perform
  doc = Nokogiri::XML(xml)
  provider_nodes = doc.xpath("//cmes/content_provider[@name='#{provider.name}']")
  expect(provider_nodes.size).to eq(1)
  # No topics → self-closing provider node (no children)
  expect(provider_nodes.first.element_children).to be_empty
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
      xml = subject.perform
      doc = Nokogiri::XML(xml)

  provider_node = doc.at_xpath("//cmes/content_provider[@name='#{provider.name}']")
      expect(provider_node).to be_present

  year_node = provider_node.at_xpath("./topic_year[@year='#{topic.published_at.year}']")
      expect(year_node).to be_present

  month_label = topic.published_at.strftime("%m_%B")
  month_node = year_node.at_xpath("./topic_month[@month='#{month_label}']")
      expect(month_node).to be_present

  title_node = month_node.at_xpath("./title[@name='#{topic.title}']")
      expect(title_node).to be_present

  expect(title_node.at_xpath("./topic_id").text).to eq(topic.id.to_s)
  expect(title_node.at_xpath("./counter").text).to eq("0")
  expect(title_node.at_xpath("./topic_volume").text).to eq(topic.published_at.year.to_s)
  expect(title_node.at_xpath("./topic_issue").text).to eq(topic.published_at.month.to_s)

  files_node = title_node.at_xpath("./topic_files[@files='Files']")
      expect(files_node).to be_present
  file1 = files_node.at_xpath("./file_name_1")
  expect(file1.text).to eq("test_image.png")
  expect(file1["file_size"]).to be_present

  author_node = title_node.at_xpath("./topic_author/topic_author_1")
  expect(author_node.text).to eq(" ")

  expect(title_node.at_xpath("./topic_tags").text).to eq(topic.current_tags_list.join(", "))
    end
  end
end
