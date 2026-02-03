require "rails_helper"

RSpec.describe Beacons::ManifestBuilder do
  subject(:builder) { described_class.new(beacon) }

  let(:language) { create(:language, name: "English") }
  let(:region) { create(:region, name: "East Region") }
  let(:provider) { create(:provider, name: "Health Ministry") }
  let(:beacon) do
    create(:beacon, language: language, region: region).tap do |b|
      b.providers << provider
    end
  end

  describe "#call" do
    context "with a beacon that has no topics" do
      it "returns manifest with empty providers topics" do
        result = builder.call

        expect(result[:language]).to eq({ id: language.id, code: "en", name: "English" })
        expect(result[:region]).to eq({ id: region.id, name: "East Region" })
        expect(result[:tags]).to eq([])
        expect(result[:providers].size).to eq(1)
        expect(result[:providers].first[:topics]).to eq([])
        expect(result[:total_size_bytes]).to eq(0)
        expect(result[:total_files]).to eq(0)
      end

      it "includes manifest metadata" do
        result = builder.call

        expect(result[:manifest_version]).to match(/\Av\d+\z/)
        expect(result[:manifest_checksum]).to start_with("sha256:")
        expect(result[:generated_at]).to be_present
      end
    end

    context "with topics and documents" do
      let(:topic) do
        create(:topic, :with_documents, title: "Maternal Health", provider: provider, language: language)
      end

      before do
        beacon.topics << topic
      end

      it "includes topic under its provider" do
        result = builder.call
        provider_data = result[:providers].first
        topic_data = provider_data[:topics].first

        expect(topic_data[:id]).to eq(topic.id)
        expect(topic_data[:name]).to eq("Maternal Health")
        expect(topic_data[:files]).not_to be_empty
      end

      it "includes file details" do
        result = builder.call
        file_data = result[:providers].first[:topics].first[:files].first
        blob = topic.documents.first.blob

        expect(file_data[:id]).to eq(blob.id)
        expect(file_data[:checksum]).to eq(blob.checksum)
        expect(file_data[:size_bytes]).to eq(blob.byte_size)
        expect(file_data[:content_type]).to eq(blob.content_type)
        expect(file_data[:path]).to start_with("providers/#{provider.id}/topics/#{topic.id}/")
      end

      it "computes correct totals" do
        result = builder.call
        blob = topic.documents.first.blob

        expect(result[:total_files]).to eq(1)
        expect(result[:total_size_bytes]).to eq(blob.byte_size)
      end
    end

    context "with tagged topics" do
      let(:topic) { create(:topic, title: "Tagged Topic", provider: provider, language: language) }

      before do
        topic.tag_list.add("Prenatal", "Emergency")
        topic.save!
        beacon.topics << topic
      end

      it "collects unique tags from topics" do
        result = builder.call

        tag_names = result[:tags].map { |t| t[:name] }
        expect(tag_names).to include("prenatal", "emergency")
      end

      it "includes tag_ids on topics" do
        result = builder.call
        topic_data = result[:providers].first[:topics].first

        expect(topic_data[:tag_ids]).to match_array(topic.tags.pluck(:id))
      end
    end

    context "with archived topics" do
      let(:active_topic) { create(:topic, title: "Active", provider: provider, language: language) }
      let(:archived_topic) { create(:topic, :archived, title: "Archived", provider: provider, language: language) }

      before do
        beacon.topics << [ active_topic, archived_topic ]
      end

      it "excludes archived topics" do
        result = builder.call
        topic_names = result[:providers].first[:topics].map { |t| t[:name] }

        expect(topic_names).to include("Active")
        expect(topic_names).not_to include("Archived")
      end
    end

    context "with multiple providers" do
      let(:provider2) { create(:provider, name: "WHO") }
      let(:topic1) { create(:topic, title: "Topic A", provider: provider, language: language) }
      let(:topic2) { create(:topic, title: "Topic B", provider: provider2, language: language) }

      before do
        beacon.providers << provider2
        beacon.topics << [ topic1, topic2 ]
      end

      it "groups topics under their respective providers" do
        result = builder.call

        provider_names = result[:providers].map { |p| p[:name] }
        expect(provider_names).to contain_exactly("Health Ministry", "WHO")

        health_provider = result[:providers].find { |p| p[:name] == "Health Ministry" }
        who_provider = result[:providers].find { |p| p[:name] == "WHO" }

        expect(health_provider[:topics].map { |t| t[:name] }).to eq([ "Topic A" ])
        expect(who_provider[:topics].map { |t| t[:name] }).to eq([ "Topic B" ])
      end
    end

    context "with a topic whose provider is not assigned to the beacon" do
      let(:unassigned_provider) { create(:provider, name: "Unassigned") }
      let(:orphaned_topic) { create(:topic, title: "Orphaned", provider: unassigned_provider, language: language) }

      before do
        beacon.topics << orphaned_topic
      end

      it "does not include orphaned topics in any provider" do
        result = builder.call

        all_topic_names = result[:providers].flat_map { |p| p[:topics].map { |t| t[:name] } }
        expect(all_topic_names).not_to include("Orphaned")
      end
    end
  end

  describe "versioning" do
    it "sets version to v1 on first call" do
      result = builder.call

      expect(result[:manifest_version]).to eq("v1")
      expect(beacon.reload.manifest_version).to eq(1)
    end

    it "keeps the same version when content has not changed" do
      builder.call
      result = described_class.new(beacon.reload).call

      expect(result[:manifest_version]).to eq("v1")
      expect(beacon.reload.manifest_version).to eq(1)
    end

    it "increments version when content changes" do
      builder.call

      topic = create(:topic, :with_documents, title: "New Topic", provider: provider, language: language)
      beacon.topics << topic

      result = described_class.new(beacon.reload).call

      expect(result[:manifest_version]).to eq("v2")
      expect(beacon.reload.manifest_version).to eq(2)
    end

    it "stores the checksum on the beacon" do
      result = builder.call

      expect(beacon.reload.manifest_checksum).to eq(result[:manifest_checksum])
    end

    it "produces stable checksum for unchanged content" do
      result1 = builder.call
      result2 = described_class.new(beacon.reload).call

      expect(result1[:manifest_checksum]).to eq(result2[:manifest_checksum])
    end
  end
end
