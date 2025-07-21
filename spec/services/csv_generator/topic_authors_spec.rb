require "rails_helper"

RSpec.describe CsvGenerator::TopicAuthors do
  subject { described_class.new(language) }

  let(:language) { create(:language) }
  let(:header) { "TopicID,AuthorID\n" }

  it "generates empty csv" do
    expect(subject.perform).to eq(header)
  end

  context "when topics exist" do
    let!(:topic) { create(:topic, language:) }

    context "when the provider has at least 1 user" do
      let!(:user) { create(:contributor, provider: topic.provider).user }
      let(:data) do
        header.tap do |csv|
          csv << "#{topic.id},#{user.id}\n"
        end
      end

      it "generates csv with topics info" do
        expect(subject.perform).to eq(data)
      end
    end

    context "when the provider has no users" do
      let(:data) do
        header.tap do |csv|
          csv << "#{topic.id},\n"
        end
      end

      it "generates csv with topics info" do
        expect(subject.perform).to eq(data)
      end
    end
  end

  context "when topic exists but archived" do
    let!(:topic) { create(:topic, :archived, language:) }

    it "generates empty csv" do
      expect(subject.perform).to eq(header)
    end
  end

  context "when topic does not belong to language" do
    let(:other_language) { create(:language) }
    let!(:topic) { create(:topic, language: other_language) }

    it "generates empty csv" do
      expect(subject.perform).to eq(header)
    end
  end
end
