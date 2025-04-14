# == Schema Information
#
# Table name: tags
#
#  id             :bigint           not null, primary key
#  name           :string
#  taggings_count :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_tags_on_name  (name) UNIQUE
#
require "rails_helper"

RSpec.describe Tag, type: :model do
  subject { create(:tag) }

  describe "associations" do
    it { should have_many(:tag_cognates) }
    it { should have_many(:cognates).through(:tag_cognates) }
    it { should have_many(:reverse_tag_cognates).class_name("TagCognate") }
    it { should have_many(:reverse_cognates).through(:reverse_tag_cognates) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe ".destroy" do
    context "when a tag has cognates" do
      let(:tag) { create(:tag) }
      let(:cognate_tag) { create(:tag) }
      let!(:tag_cognate) { create(:tag_cognate, tag: tag, cognate: cognate_tag) }

      it "destroys all associated tag cognates" do
        expect { tag.destroy }
          .to change { TagCognate.exists?(tag_id: tag.id, cognate_id: cognate_tag.id) }
          .from(true)
          .to(false)
      end
    end
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

  describe ".cognates_list=" do
    context "when setting cognates" do
      let(:cognate_tag) { create(:tag) }
      let!(:existing_cognate) { create(:tag) }

      it "adds new cognates to the tag" do
        subject.cognates_list = [ cognate_tag.name ]
        expect(subject.cognates_tags).to include(cognate_tag)
      end

      context "when existing cognates are present" do
        let(:new_cognate_tag) { create(:tag) }

        before do
          create(:tag_cognate, tag: subject, cognate: existing_cognate)
        end

        it "replaces old cognates with new ones" do
          subject.cognates_list = [ new_cognate_tag.name ]

          aggregate_failures do
            expect(subject.cognates_tags).to include(new_cognate_tag)
            expect(subject.cognates_tags).not_to include(existing_cognate)
          end
        end
      end
    end

    context "when setting an empty cognates list" do
      before do
        create(:tag_cognate, tag: subject, cognate: create(:tag))
      end

      it "removes all cognates" do
        subject.cognates_list = []
        expect(subject.cognates_tags).to be_empty
      end
    end
  end

  describe ".all_available_tags" do
    it "returns all tags that are not cognates of the given tag" do
      cognate_tag = create(:tag)
      create(:tag_cognate, tag: subject, cognate: cognate_tag)

      expect(subject.all_available_tags).to include(cognate_tag)
      expect(subject.all_available_tags).not_to include(subject)
    end
  end
end
