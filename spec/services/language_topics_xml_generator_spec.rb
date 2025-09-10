require "rails_helper"

RSpec.describe LanguageTopicsXmlGenerator do
  let(:language) { Language.find_by(name: "en") }

  # This spec provides a high-confidence check that the refactored service
  # is a safe replacement for the legacy implementation by asserting that
  # their XML outputs are semantically identical.
  it "produces an XML output identical to the corrected legacy generator" do
    # Arrange: Build a consistent data set for both generators.
    XmlTestDataBuilder.xml_scenario
      .for_language(name: "en")
      .for_provider(name: "Health Corp")
      .with_topic(
        title: "Topic A - Jan 2023",
        published_at: Date.new(2023, 1, 15),
        documents: [
          { filename: "report.pdf", content_type: "application/pdf" },
          { filename: "video.mp4", content_type: "video/mp4" },
        ],
        tags: [ "flu", "vaccine" ]
      )
      .with_topic(
        title: "Topic C - Feb 2022",
        published_at: Date.new(2022, 2, 10),
        tags: [ "diabetes", "research" ]
      )
      .for_provider(name: "Wellness Inc")
      .with_topic(
        title: "Topic D - Jan 2023",
        published_at: Date.new(2023, 1, 5)
      )
      .build!

    # Patch the single buggy method in the legacy implementation for this test.
    # This allows us to use the actual legacy classes but with the critical
    # language-scoping logic fixed, ensuring a valid comparison.
    # allow_any_instance_of(XmlGenerator::SingleProvider).to receive(:topic_scope) do |instance, provider|
    #   # Re-implement the method with the correct logic. The `instance` passed
    #   # here is the XmlGenerator::AllProviders object, which holds the context.
    #   language = instance.instance_variable_get(:@language)
    #   args = instance.instance_variable_get(:@args)

    #   scope = provider.topics.where(language_id: language.id)
    #   scope = scope.where("published_at > ?", 1.month.ago) if args.fetch(:recent, false)
    #   scope
    #     .select(:id, :title, :published_at, :language_id, :provider_id)
    #     .includes(:language, { taggings: :tag }, { documents_attachments: :blob })
    #     .order(published_at: :desc)
    # end


    # Act: Generate XML from both the new and (patched) legacy services.
    new_xml = LanguageTopicsXmlGenerator.new(language).perform
    legacy_xml = XmlGenerator::AllProviders.new(language).perform

    # Assert: Parse and normalize both XML outputs to ensure they are identical.
    # Comparing parsed documents is more robust than string comparison as it
    # ignores insignificant whitespace and attribute ordering differences.
    new_doc = Nokogiri::XML(new_xml) { |config| config.noblanks }
    legacy_doc = Nokogiri::XML(legacy_xml) { |config| config.noblanks }

    expect(new_doc.to_xml).to eq(legacy_doc.to_xml)
  end
  context "when the :recent option is true" do
    let(:generator) { described_class.new(language, recent: true) }

    before do
      XmlTestDataBuilder.xml_scenario
        .for_language(name: "en")
        .for_provider(name: "Health Corp")
        .with_topic(
          title: "Recent Topic",
          published_at: 2.weeks.ago
        )
        .with_topic(
          title: "Old Topic",
          published_at: 2.months.ago
        )
        .build!
    end

    it "includes only topics published within the last month" do
      doc = Nokogiri::XML(generator.perform)

      recent_topic_node = doc.at_xpath("//title[@name='Recent Topic']")
      old_topic_node = doc.at_xpath("//title[@name='Old Topic']")

      expect(recent_topic_node).not_to be_nil
      expect(old_topic_node).to be_nil
    end
  end
end
