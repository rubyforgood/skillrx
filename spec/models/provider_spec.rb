require "rails_helper"

RSpec.describe Provider, type: :model do
  describe "associations" do
    it { should have_many(:branches) }
    it { should have_many(:regions).through(:branches) }
    it { should have_many(:contributors) }
    it { should have_many(:users).through(:contributors) }
    it { should have_many(:topics) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:provider_type) }
    it { should validate_uniqueness_of(:name) }
  end

  describe "#name_for_filename" do
    let(:provider) { described_class.new(name: "Test Provider", file_name_prefix: nil) }

    it "parameterizes the name if file_name_prefix is not present" do
      expect(provider.name_for_filename).to eq("test-provider")
    end

    it "parameterizes the file_name_prefix if present" do
      provider.file_name_prefix = "Prefix Name"
      expect(provider.name_for_filename).to eq("prefix-name")
    end
  end
end
