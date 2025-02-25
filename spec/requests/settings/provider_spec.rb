require "rails_helper"

describe "Settings", type: :request do
  describe "PUT /settings/provider" do
    let(:user) { create(:user) }
    let(:provider) { create(:provider) }

    before { sign_in(user) }

    context "when provider cannot be found" do
      it "does not update current provider" do
        put provider_settings_url, params: { id: provider.id }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when user has access to provider" do
      before do
        user.providers << provider
      end

      it "updates current provider" do
        put provider_settings_url, params: { id: provider.id }

        signed_cookies = ActionDispatch::Request.new(Rails.application.env_config).cookie_jar

        expect(response).to redirect_to(root_url)
        expect(signed_cookies.signed[:current_provider_id]).to eq(provider.id)
      end
    end
  end
end
