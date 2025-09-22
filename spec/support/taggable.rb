RSpec.shared_examples "taggable" do
  let(:model) { described_class }
  let(:language) { create(:language, name: "English") }
  let(:instance) { create(model.to_s.underscore.to_sym, language: language) }

  describe "module inclusion" do
    it "includes required modules" do
      expect(model.included_modules).to include(Taggable)
    end
  end

  describe "#available_tags" do
    before do
      instance.set_tag_list_on(language.code.to_sym, "hiv")
      instance.save
    end

    it "returns all tags not associated with the instance" do
      other_tag = create(:tag, name: "other")
      expect(instance.available_tags).to eq([other_tag])
    end
  end

  describe "#current_tags_list" do
    before do
      instance.set_tag_list_on(language.code.to_sym, "hiv")
      instance.save
    end

    it "returns tags associated to the instance" do
      expect(instance.current_tags_list).to eq(["hiv"])
    end
  end

  describe "#language_code" do
    it "returns the instance's language code as a symbol" do
      expect(instance.language_code).to eq(:en)
    end
  end

  describe "#save_with_tags" do
    let(:tag_list) { [ "malaria", "fever" ] }
    let(:attrs) { { title: "New Title", tag_list: tag_list } }

    it "processes tags correctly" do
      instance.save_with_tags(attrs)
      expect(instance.reload.title).to eq("New Title")
      expect(instance.current_tags_list).to match_array(tag_list)
    end

    context "when adding tags that have cognates or reverse cognates" do
      let(:english_cognate) { create(:tag, name: "paludism") }
      let(:english_reverse_cognate) { create(:tag, name: "jungle fever") }
      let(:spanish_cognate) { create(:tag, name: "paludismo") }
      let(:spanish_reverse_cognate) { create(:tag, name: "fiebre de la jungla") }

      before do
        tag1 = create(:tag, name: tag_list.first)
        create(:tag_cognate, tag: tag1, cognate: english_cognate)
        create(:tag_cognate, tag: tag1, cognate: spanish_cognate)
        create(:tag_cognate, tag: english_reverse_cognate, cognate: tag1)
        create(:tag_cognate, tag: spanish_reverse_cognate, cognate: tag1)
        english_instance = create(described_class.to_s.underscore.to_sym, language: language)
        spanish_instance = create(described_class.to_s.underscore.to_sym, language: create(:language, name: "Spanish"))
        english_instance.set_tag_list_on(:en, "paludism,jungle fever")
        english_instance.save
        spanish_instance.set_tag_list_on(:sp, "paludismo,fiebre de la jungla")
        spanish_instance.save
      end

      it "adds the cognates of both languages as well" do
        instance.save_with_tags(attrs)
        expect(instance.reload.title).to eq("New Title")
        expect(instance.current_tags_list).to match_array(tag_list.push(english_cognate.name, english_reverse_cognate.name, spanish_cognate.name, spanish_reverse_cognate.name))
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
        create(:tag_cognate, tag: reverse_cognate, cognate: cognate)
        tags_and_their_cognates = tag_list.push(cognate.name, reverse_cognate.name)
        instance.set_tag_list_on(instance.language_code, tags_and_their_cognates)
        instance.save
      end

      it "removes the cognates as well" do
        instance.save_with_tags(attrs)
        expect(instance.reload.title).to eq("New Title")
        expect(instance.reload.current_tags_list).to eq([ "tags" ])
      end
    end
  end
end
