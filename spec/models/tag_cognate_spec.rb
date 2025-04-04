require "rails_helper"

RSpec.describe TagCognate, type: :model do
  describe "associations" do
    it { should belong_to(:tag) }
    it { should belong_to(:cognate).class_name("Tag") }
  end

  describe "validations" do
    let(:tag) { create(:tag) }
    let(:cognate) { create(:tag) }
    subject { build(:tag_cognate, tag: tag, cognate: cognate) }

    it "validates uniqueness of cognate scoped to tag" do
      should validate_uniqueness_of(:tag_id).scoped_to(:cognate_id)
    end

    it "prevents self-referential relationships" do
      tag_cognate = build(:tag_cognate, tag: tag, cognate: tag)

      expect(tag_cognate).not_to be_valid
      expect(tag_cognate.errors[:base]).to include("Tag can't be its own cognate")
    end
  end
end
