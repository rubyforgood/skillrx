require "rails_helper"

describe "Languages", type: :request do
  describe "POST /languages" do
    let(:user) { create(:user, :admin) }
    let(:language_params) { { name: "french" } }

    before { sign_in(user) }

    it "creates a Language" do
      post languages_url, params: { language: language_params }

      expect(response).to redirect_to(languages_path)
      expect(Language.last.name).to eq("french")
      expect(Language.last.file_share_folder).to eq("languages/french")
    end
  end
end
