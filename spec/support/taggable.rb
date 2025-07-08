RSpec.shared_examples "taggable" do
  let(:model) { described_class }
  let(:language) { create(:language, name: "English") }
  let(:instance) { create(model.to_s.underscore.to_sym, language: language) }

  describe "module inclusion" do
    it "includes required modules" do
      expect(model.included_modules).to include(Taggable)
    end
  end

  describe "#language_tag_context" do
    context "when language is present" do
      it "returns language iso code as symbol" do
        expect(instance.language_tag_context).to eq(:en)
      end
    end

    context "when language is nil" do
      before { instance.language = nil }

      it "raises LanguageContextError" do
        expect { instance.language_tag_context }
          .to raise_error(Taggable::LanguageContextError, "Language must be present")
      end
    end
  end

  describe "#available_tags" do
    it "delegates to ActsAsTaggableOn::Tag with correct context" do
      tag_collection = double("tag_collection")
      expect(ActsAsTaggableOn::Tag).to receive(:for_context).with(:en).and_return(tag_collection)
      expect(tag_collection).to receive(:order).with(name: :asc)
      instance.available_tags
    end
  end

  describe "#current_tags_list" do
    it "returns tags for the language context" do
      expect(instance).to receive(:tag_list_on).with(:en)
      instance.current_tags_list
    end
  end

  describe "#save_with_tags" do
    let(:tag_list) { [ "test", "tags" ] }
    let(:attrs) { { title: "New Title", tag_list: tag_list } }

    it "processes tags correctly" do
      instance.save_with_tags(attrs)
      expect(instance.reload.title).to eq("New Title")
      expect(instance.current_tags_list).to eq(tag_list)
    end

    context "when adding tags that have cognates or reverse cognates" do
      let(:cognate) { create(:tag, name: "cognate") }
      let(:reverse_cognate) { create(:tag, name: "reverse cognate") }

      before do
        tag1 = create(:tag, name: tag_list.first)
        create(:tag_cognate, tag: tag1, cognate: cognate)
        create(:tag_cognate, tag: reverse_cognate, cognate: tag1)
      end

      it "adds the cognates as well" do
        instance.save_with_tags(attrs)
        expect(instance.reload.title).to eq("New Title")
        expect(instance.current_tags_list).to match_array(tag_list.push(cognate.name, reverse_cognate.name))
      end
    end

    context "when removing tags that have cognates or reverse cognates" do
      let(:cognate) { create(:tag, name: "cognate") }
      let(:reverse_cognate) { create(:tag, name: "reverse cognate") }
      let(:attrs) { { title: "New Title", tag_list: [ "", "tags", "cognate", "reverse cognate" ] } }

      before do
        tag1 = create(:tag, name: tag_list.first)
        create(:tag_cognate, tag: tag1, cognate: cognate)
        create(:tag_cognate, tag: reverse_cognate, cognate: tag1)
        tags_and_their_cognates = tag_list.push(cognate.name, reverse_cognate.name)
        instance.set_tag_list_on(instance.language.code.to_sym, tags_and_their_cognates)
      end

      it "removes the cognates as well" do
        instance.save_with_tags(attrs)
        expect(instance.reload.title).to eq("New Title")
        expect(instance.current_tags_list).to eq([ "tags" ])
      end
    end
  end
end
