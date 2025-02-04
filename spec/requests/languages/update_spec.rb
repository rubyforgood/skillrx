require "rails_helper"

describe "Languages", type: :request do
  describe "PUT /languages" do
    let(:user) { create(:user, :admin) }

    before { sign_in(user) }

    it "updates a Language" do
      language = create(:language)
      language_params = { name: "french", file_share_folder: "languages/french" }

      put language_url(language), params: { language: language_params }

      language.reload
      expect(response).to redirect_to(languages_path)
      expect(language.name).to eq("french")
      expect(language.file_share_folder).to eq("languages/french")
    end
  end
end
