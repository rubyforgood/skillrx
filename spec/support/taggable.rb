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
        expect(ActsAsTaggableOn::Tag).to receive(:for_context).with(:en)
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
      it "processes tags correctly" do
        tag_list = ["test", "tags"]
        attrs = { title: "New Title", tag_list: tag_list }
        
        expect(instance).to receive(:update).with({ title: "New Title" }).and_return(true)
        expect(instance).to receive(:process_tags).with(tag_list)
        
        instance.save_with_tags(attrs)
      end
    end
end