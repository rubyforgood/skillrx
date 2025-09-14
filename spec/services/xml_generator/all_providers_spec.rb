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
      pnode = doc.at_xpath("//CMES/Content_Provider[@name='#{prov.name}']")
      expect(pnode).to be_present
    end

    [ [ provider1, topic1 ], [ provider2, topic2 ] ].each do |prov, topic|
      pnode = doc.at_xpath("//CMES/Content_Provider[@name='#{prov.name}']")
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

  it "does not duplicate topic_year per provider across batches" do
    # Create providers and topics spanning multiple months/years for one provider
    provider3 = create(:provider)

    # Provider 1: multiple topics in same year and month + another month and another year
    create(:topic, language:, provider: provider1, published_at: Time.zone.parse("2024-01-15"))
    create(:topic, language:, provider: provider1, published_at: Time.zone.parse("2024-01-20"))
    create(:topic, language:, provider: provider1, published_at: Time.zone.parse("2024-03-05"))
    create(:topic, language:, provider: provider1, published_at: Time.zone.parse("2023-07-01"))

    # Other providers to force multiple batches
    create(:topic, language:, provider: provider2, published_at: Time.zone.parse("2023-01-01"))
    create(:topic, language:, provider: provider3, published_at: Time.zone.parse("2024-02-01"))

    # Stub batching to yield two slices, simulating multiple provider-id batches
    allow_any_instance_of(described_class)
      .to receive(:provider_ids_in_language_in_batches)
      .and_yield([ provider1.id, provider2.id ])
      .and_yield([ provider3.id ])

    xml = subject.perform
    doc = Nokogiri::XML(xml)

    pnode = doc.at_xpath("//CMES/Content_Provider[@name='#{provider1.name}']")
    expect(pnode).to be_present

    years = pnode.xpath("./topic_year/@year").map(&:value)
    # Expect no duplicate year nodes for the provider
    expect(years.tally.values.max).to eq(1)

    # Specifically ensure 2024 appears once with months Jan and Mar once each
    y2024 = pnode.at_xpath("./topic_year[@year='2024']")
    expect(y2024).to be_present

    months_2024 = y2024.xpath("./topic_month/@month").map(&:value)
    expect(months_2024).to include("01_January", "03_March")
    expect(months_2024.tally["01_January"]).to eq(1)
    expect(months_2024.tally["03_March"]).to eq(1)
  end

  it "does not duplicate topic_month within a year for a provider" do
    # Create multiple topics for provider1 in the same month/year and another month in the same year
    create(:topic, language:, provider: provider1, published_at: Time.zone.parse("2024-02-01"))
    create(:topic, language:, provider: provider1, published_at: Time.zone.parse("2024-02-10"))
    create(:topic, language:, provider: provider1, published_at: Time.zone.parse("2024-03-05"))

    xml = subject.perform
    doc = Nokogiri::XML(xml)

    pnode = doc.at_xpath("//CMES/Content_Provider[@name='#{provider1.name}']")
    expect(pnode).to be_present

    y2024 = pnode.at_xpath("./topic_year[@year='2024']")
    expect(y2024).to be_present

    months = y2024.xpath("./topic_month/@month").map(&:value)
    # months should be unique (no duplicate month nodes)
    expect(months.uniq.size).to eq(months.size)
    expect(months).to include("02_February", "03_March")
    expect(months.tally["02_February"]).to eq(1)
    expect(months.tally["03_March"]).to eq(1)
  end
end
