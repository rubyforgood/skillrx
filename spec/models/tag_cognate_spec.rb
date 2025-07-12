# == Schema Information
#
# Table name: tag_cognates
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cognate_id :bigint
#  tag_id     :bigint
#
# Indexes
#
#  index_tag_cognates_on_cognate_id             (cognate_id)
#  index_tag_cognates_on_tag_id                 (tag_id)
#  index_tag_cognates_on_tag_id_and_cognate_id  (tag_id,cognate_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (cognate_id => tags.id)
#  fk_rails_...  (tag_id => tags.id)
#
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

    context "when a reverse TagCognate with the same Tag/Cognate combination already exists" do
      let!(:reverse_tag_cognate) { create(:tag_cognate, tag: cognate, cognate: tag) }
      let(:tag_cognate) { build(:tag_cognate, tag: tag, cognate: cognate) }

      it "prevents creation of duplicate TagCognate" do
        expect(tag_cognate).not_to be_valid
        expect(tag_cognate.errors[:base]).to include("This cognate relationship already exists in reverse")
      end
    end
  end
end
