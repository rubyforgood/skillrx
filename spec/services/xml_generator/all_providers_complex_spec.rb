require "rails_helper"

RSpec.describe XmlGenerator::AllProviders do
  let(:language) { Language.find_by!(name: "en") }
  subject { described_class.new(language) }

  context "with a complex data set" do
    before do
      # Arrange: Use the builder to create a rich scenario
      XmlTestDataBuilder.xml_scenario
        .for_language(name: "en")
        .for_provider(name: "Health Corp")
        .with_topic(
          title: "Topic A - Jan 2023",
          published_at: Date.new(2023, 1, 15),
          documents: [
            { filename: "report.pdf", content_type: "application/pdf" },
            { filename: "video.mp4", content_type: "video/mp4" }, # This should be excluded
          ]
        )
        .with_topic(
          title: "Topic B - Jan 2023",
          published_at: Date.new(2023, 1, 20) # Same month, different day
        )
        .with_topic(
          title: "Topic C - Feb 2022",
          published_at: Date.new(2022, 2, 10),
          tags: [ "diabetes", "research" ]
        )
        .for_provider(name: "Wellness Inc") # Switch to a different provider
        .with_topic(
          title: "Topic D - Jan 2023",
          published_at: Date.new(2023, 1, 5)
        )
        .build!
    end

    it "groups topics correctly by provider, year, and month" do
      # Act
      doc = Nokogiri::XML(subject.perform)

      # Assert on provider and year structure
      provider1_node = doc.at_xpath("//content_provider[@name='Health Corp']")
      provider2_node = doc.at_xpath("//content_provider[@name='Wellness Inc']")
      expect(provider1_node).not_to be_nil
      expect(provider2_node).not_to be_nil

      # Assert years are sorted descending
      years_for_p1 = provider1_node.xpath("./topic_year").map { |n| n["year"] }
      expect(years_for_p1).to eq([ "2023", "2022" ])

      # Assert on month grouping for Health Corp, 2023
      year_2023_node = provider1_node.at_xpath("./topic_year[@year='2023']")
      month_jan_node = year_2023_node.at_xpath("./topic_month[@month='01_January']")
      expect(month_jan_node).not_to be_nil

      # Assert topics within the month are present
      topic_titles = month_jan_node.xpath("./title").map { |n| n["name"] }
      expect(topic_titles).to contain_exactly("Topic A - Jan 2023", "Topic B - Jan 2023")
    end

    it "filters out video documents" do
      doc = Nokogiri::XML(subject.perform)

      topic_a_node = doc.at_xpath("//title[@name='Topic A - Jan 2023']")
      files_node = topic_a_node.at_xpath("./topic_files")

      # Assert only the non-video file is listed
      expect(files_node.element_children.count).to eq(1)
      expect(files_node.at_xpath("./file_name_1").text).to eq("report.pdf")
      expect(files_node.at_xpath("./file_name_1")["file_size"]).not_to be_nil
    end

    it "renders tags correctly" do
      doc = Nokogiri::XML(subject.perform)
      topic_c_node = doc.at_xpath("//title[@name='Topic C - Feb 2022']")
      tags_node = topic_c_node.at_xpath("./topic_tags")

      expect(tags_node.text).to eq("diabetes, research")
    end
  end
end
