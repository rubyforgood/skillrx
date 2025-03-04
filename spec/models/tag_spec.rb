require "rails_helper"

RSpec.describe Tag, type: :model do
  subject { create(:tag) }

  describe "associations" do
    it { should have_many(:tag_cognates) }
    it { should have_many(:cognates).through(:tag_cognates) }
    it { should have_many(:reverse_tag_cognates).class_name("TagCognate") }
    it { should have_many(:reverse_cognates).through(:reverse_tag_cognates) }
  end

  describe ".cognates_tags" do
    it "returns all tags that are cognates of the given tag" do
      cognate_tag = create(:tag)
      create(:tag_cognate, tag: subject, cognate: cognate_tag)

      expect(subject.cognates_tags).to include(cognate_tag)
    end

    context "with reverse cognates" do
      it "returns all tags that are cognates of the given tag" do
        another_tag = create(:tag)
        create(:tag_cognate, tag: another_tag, cognate: subject)

        expect(subject.cognates_tags).to include(another_tag)
      end
    end
  end

  describe ".cognates_list" do
    it "returns all tags that are cognates of the given tag" do
      cognate_tag = create(:tag)
      create(:tag_cognate, tag: subject, cognate: cognate_tag)

      expect(subject.cognates_list).to include(cognate_tag.name)
    end

    context "with reverse cognates" do
      it "returns all tags that are cognates of the given tag" do
        another_tag = create(:tag)
        create(:tag_cognate, tag: another_tag, cognate: subject)

        expect(subject.cognates_list).to include(another_tag.name)
      end
    end
  end

  describe ".available_cognates" do
    it "returns all tags that are not cognates of the given tag" do
      non_cognate_tags = create_list(:tag, 2)
      cognate_tag = create(:tag)
      create(:tag_cognate, tag: subject, cognate: cognate_tag)

      expect(subject.available_cognates).not_to include(cognate_tag)
      expect(subject.available_cognates).to be_all { |tag| non_cognate_tags.include?(tag) }
    end
  end
end
