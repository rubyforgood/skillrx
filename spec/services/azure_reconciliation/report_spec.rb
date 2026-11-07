require "rails_helper"

RSpec.describe AzureReconciliation::Report do
  subject(:report) { described_class.new(lister:, languages: [ language ], check_blobs:) }

  let(:language) { create(:language, name: "English") }
  let(:provider) { create(:provider, file_name_prefix: "emdoc") }
  let(:check_blobs) { false }
  let(:azure) { Hash.new { |h, k| h[k] = {} } }
  let(:lister) { FakeLister.new(azure) }

  let(:pi) { "CMES-Pi/assets/Content" }
  let(:v2) { "CMES-v2/assets/Content" }
  let(:video) { "CMES-v2/assets/VideoContent" }
  let(:pi_archive) { "CMES-Pi_Archive" }
  let(:v2_archive) { "CMES-v2_Archive" }

  FakeLister = Struct.new(:azure) do
    def files_in(directory)
      azure.key?(directory) ? azure[directory] : nil
    end
  end

  def create_topic(state: :active, title: "Sepsis", published_at: Time.zone.local(2026, 5, 2), **attrs)
    create(:topic, language:, provider:, title:, state:, published_at:, **attrs)
  end

  def attach(topic, content: "pdf-bytes", name: "sepsis.pdf", content_type: "application/pdf")
    topic.documents.attach(
      io: StringIO.new(content),
      filename: "#{Topic::INTERNAL_FILENAME_PREFIX}_#{name}",
      content_type:,
    )
    topic.documents.last
  end

  def place(topic, document, *directories, size: document.byte_size)
    directories.each { |dir| azure[dir][topic.custom_file_name(document)] = size }
  end

  def categories
    report.rows.map(&:category)
  end

  before do
    [ pi, v2, video, pi_archive, v2_archive ].each { |dir| azure[dir] }
  end

  it "reports nothing when every document is where it should be" do
    topic = create_topic
    place(topic, attach(topic), pi, v2)

    expect(report.rows).to be_empty
  end

  it "reports active topics with no documents" do
    topic = create_topic

    expect(report.rows).to contain_exactly(have_attributes(category: "topic_without_documents", topic_id: topic.id))
  end

  it "reports a document missing from one Azure folder" do
    topic = create_topic
    document = attach(topic)
    place(topic, document, pi)

    expect(report.rows).to contain_exactly(
      have_attributes(category: "missing_in_azure", topic_id: topic.id, document_id: document.id, directory: v2),
    )
  end

  it "reports a size mismatch" do
    topic = create_topic
    document = attach(topic)
    place(topic, document, pi, v2)
    place(topic, document, v2, size: 3)

    expect(report.rows).to contain_exactly(
      have_attributes(category: "size_mismatch", directory: v2, expected_size: document.byte_size, azure_size: 3),
    )
  end

  it "reports 0 byte documents" do
    topic = create_topic
    attach(topic, content: "")

    expect(categories).to include("empty_document")
  end

  it "expects videos only in the video folder" do
    topic = create_topic
    document = attach(topic, name: "talk.mp4", content_type: "video/mp4")
    place(topic, document, video)

    expect(report.rows).to be_empty
  end

  it "expects archived topics' files in the archive folders" do
    topic = create_topic(state: :archived)
    place(topic, attach(topic), pi_archive, v2_archive)

    expect(report.rows).to be_empty
  end

  it "reports a file left in the active folder after archiving as wrong_folder" do
    topic = create_topic(state: :archived)
    document = attach(topic)
    place(topic, document, pi, v2_archive)

    expect(report.rows).to contain_exactly(
      have_attributes(category: "wrong_folder", directory: pi_archive, note: "found in #{pi}"),
    )
  end

  it "reports a stale copy when the file is in both the active and archive folders" do
    topic = create_topic(state: :archived)
    place(topic, attach(topic), pi_archive, v2_archive, pi)

    expect(report.rows).to contain_exactly(have_attributes(category: "orphan_stale_copy", directory: pi, topic_id: topic.id))
  end

  describe "pending deletes" do
    let(:topic) { create_topic }
    let(:shadow) { create_topic(shadow_copy: true, document_prefix: topic.id) }

    it "reports a deleted document still in Azure as failed_delete" do
      place(topic, attach(topic, name: "new.pdf"), pi, v2)
      place(shadow, attach(shadow, name: "old.pdf"), pi)

      expect(report.rows).to contain_exactly(have_attributes(category: "failed_delete", directory: pi, topic_id: topic.id))
    end

    it "does not report a delete when a current document has the same file name" do
      place(topic, attach(topic), pi, v2)
      attach(shadow)

      expect(report.rows).to be_empty
    end
  end

  describe "files in Azure that match no document" do
    it "reports a file for an existing topic under another name" do
      topic = create_topic
      place(topic, attach(topic), pi, v2)
      azure[pi]["#{topic.id}_emdoc_2025_1_sepsis.pdf"] = 10

      expect(report.rows).to contain_exactly(
        have_attributes(category: "orphan_unmatched_name", topic_id: topic.id, file_name: "#{topic.id}_emdoc_2025_1_sepsis.pdf"),
      )
    end

    it "reports a file whose topic no longer exists" do
      azure[v2]["999999_emdoc_2026_5_gone.pdf"] = 10

      expect(report.rows).to contain_exactly(have_attributes(category: "orphan_no_topic", topic_id: nil, azure_size: 10))
    end
  end

  it "reports duplicate topics" do
    first = create_topic(title: "Journal Feed Weekly Wrap Up May 2")
    second = create_topic(title: "journal feed weekly wrap up may 2 ")
    [ first, second ].each { |topic| place(topic, attach(topic, name: "wrap.pdf"), pi, v2) }

    expect(report.rows.select { _1.category == "duplicate_topic" }.map(&:topic_id)).to contain_exactly(first.id, second.id)
  end

  describe "#to_csv and #summary" do
    before do
      create_topic(title: "Empty one")
      create_topic(title: "Empty two")
    end

    it "writes one CSV line per row with a header" do
      csv = CSV.parse(report.to_csv, headers: true)

      expect(csv.headers).to eq(AzureReconciliation::Report::Row.members.map(&:to_s))
      expect(csv.map { _1["title"] }).to contain_exactly("Empty one", "Empty two")
    end

    it "counts rows by language and category" do
      expect(report.summary).to eq({ [ "English", "topic_without_documents" ] => 2 })
    end
  end

  it "reports an Azure folder that does not exist" do
    azure.delete(video)

    expect(report.rows).to contain_exactly(have_attributes(category: "missing_directory", directory: video))
  end

  it "uses the language prefix for folder names" do
    spanish = create(:language, name: "Spanish")
    topic = create(:topic, language: spanish, provider:)
    place(topic, attach(topic), "SP_#{pi}", "SP_#{v2}")
    %w[SP_CMES-v2/assets/VideoContent SP_CMES-Pi_Archive SP_CMES-v2_Archive].each { |dir| azure[dir] }

    rows = described_class.new(lister:, languages: [ spanish ], check_blobs: false).rows

    expect(rows).to be_empty
  end

  context "when checking blobs in storage" do
    let(:check_blobs) { true }

    it "reports a document whose file is missing from storage" do
      topic = create_topic
      document = attach(topic)
      place(topic, document, pi, v2)
      document.blob.service.delete(document.blob.key)

      expect(report.rows).to contain_exactly(have_attributes(category: "missing_in_storage", document_id: document.id))
    end
  end
end
