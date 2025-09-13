# == Schema Information
#
# Table name: topics
#
#  id              :bigint           not null, primary key
#  description     :text
#  document_prefix :string
#  published_at    :datetime         not null
#  shadow_copy     :boolean          default(FALSE), not null
#  state           :integer          default("active"), not null
#  title           :string           not null
#  uid             :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  language_id     :bigint
#  old_id          :integer
#  provider_id     :bigint
#
# Indexes
#
#  index_topics_on_language_id   (language_id)
#  index_topics_on_old_id        (old_id) UNIQUE
#  index_topics_on_provider_id   (provider_id)
#  index_topics_on_published_at  (published_at)
#
require "rails_helper"

RSpec.describe Topic, type: :model do
  subject { create(:topic) }

  context "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:language_id) }
    it { is_expected.to validate_presence_of(:provider_id) }
  end

  context "associations" do
    it { is_expected.to have_many_attached(:documents) }
    it { is_expected.to validate_content_type_of(:documents).allowing("image/png", "image/jpeg", "image/svg+xml", "image/webp", "image/avif", "image/gif", "video/mp4") }
    it { is_expected.to validate_size_of(:documents).less_than(200.megabytes) }
  end

  context "tagging" do
    it_behaves_like "taggable"
  end

  describe "#custom_file_name" do
    let(:document) { double("Document", filename: ActiveStorage::Filename.new("document_name.pdf")) }
    let(:topic) { create(:topic, provider: provider, published_at: Time.new(2023, 12, 22)) }

    context "when provider has a file name prefix" do
      let(:provider) { create(:provider, file_name_prefix: "prefix") }

      it "returns file name" do
        expect(topic.custom_file_name(document)).to eq("document_name.pdf")
      end

      context "when document filename is prefixed with [skillrx_internal_upload]" do
        let(:document) do
          double("Document", filename: ActiveStorage::Filename.new("[skillrx_internal_upload]_document_name.pdf"))
        end

        it "returns a custom file name based on topic attributes" do
          expect(topic.custom_file_name(document)).to eq(
            "#{topic.id}_prefix_2023_12_document_name.pdf"
          )
        end
      end
    end

    context "when provider does not have a file name prefix" do
      let(:provider) { create(:provider, file_name_prefix: nil, name: "Provider Name") }

      it "returns file name" do
        expect(topic.custom_file_name(document)).to eq("document_name.pdf")
      end

      context "when document filename is prefixed with [skillrx_internal_upload]" do
        let(:document) do
          double("Document", filename: ActiveStorage::Filename.new("[skillrx_internal_upload]_document_name.pdf"))
        end

        it "returns a custom file name based on topic attributes" do
          expect(topic.custom_file_name(document)).to eq(
            "#{topic.id}_provider_name_2023_12_document_name.pdf"
          )
        end
      end
    end
  end
end
