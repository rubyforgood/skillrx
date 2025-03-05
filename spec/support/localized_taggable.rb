RSpec.shared_examples "localized taggable" do
  let(:model) { described_class }
  let(:language) { create(:language, name: "English") }
  let(:instance) { create(model.to_s.underscore.to_sym, language: language) }

  describe "module inclusion" do
    it "includes required modules" do
      expect(model.included_modules).to include(LocalizedTaggable)
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
          .to raise_error(LocalizedTaggable::LanguageContextError, "Language must be present")
      end
    end
  end

  describe "#available_tags" do
    it "delegates to ActsAsTaggableOn::Tag with correct context" do
      expect(ActsAsTaggableOn::Tag).to receive(:for_context).with(:en)
      instance.available_tags
    end
  end

  describe "#current_tags" do
    it "returns tags for the language context" do
      expect(instance).to receive(:tag_list_on).with(:en)
      instance.current_tags
    end
  end
end
