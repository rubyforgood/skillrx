require "rails_helper"

describe "Languages", type: :request do
  describe "PUT /languages" do
    let(:user) { create(:user, :admin) }
    let(:language) { create(:language) }
    let(:language_params) { { name: "french" } }

    before { sign_in(user) }

    it "updates a Language" do
      put language_url(language), params: { language: language_params }

      language.reload
      expect(response).to redirect_to(languages_path)
      expect(language.name).to eq("french")
      expect(language.file_storage_prefix).to eq("FR_")
    end

    it "displays a success message" do
      put language_url(language), params: { language: language_params }

      expect(flash[:notice]).to eq("Language was successfully updated.")
    end
  end
end
