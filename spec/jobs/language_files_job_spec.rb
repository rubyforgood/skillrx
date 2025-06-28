require "rails_helper"

RSpec.describe LanguageFilesJob, type: :job do
  let(:language) { create(:language) }

  describe "#perform" do
    it "processes the language content" do
      processor = instance_double(LanguageContentProcessor)
      allow(LanguageContentProcessor).to receive(:new).with(language).and_return(processor)
      expect(processor).to receive(:perform)

      described_class.perform_now(language.id)
    end

    context "when language does not exist" do
      it "raises an error" do
        expect { described_class.perform_now(-1) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
