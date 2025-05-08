require "rails_helper"

RSpec.describe LanguageFilesScheduler do
  subject { described_class.new.perform }

  let!(:language) { create(:language) }

  before do
    allow(LanguageFilesJob).to receive(:perform_later)
  end

  it "calls LanguageFilesJob for each language" do
    subject

    expect(LanguageFilesJob).to have_received(:perform_later).with(language.id)
  end
end
