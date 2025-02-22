require "rails_helper"

RSpec.describe Language, type: :model do
  subject { create(:language, name: name) }

  context "validations" do
    let(:name) { Faker::Name.name }
    it { should validate_presence_of(:name) }
  end

  describe ".file_storage_prefix" do
    context "when storage_prefix is English" do
      let(:name) { "English" }

      it "returns an empty string" do
        expect(subject.file_storage_prefix).to eq("")
      end
    end

    context "when storage_prefix is different than English" do
      let(:name) { "French" }

      it "returns a string with the first two characters of the name, capitalized, followed by an underscore" do
        expect(subject.file_storage_prefix).to eq("FR_")
      end
    end
  end
end
