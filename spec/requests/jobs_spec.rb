require "rails_helper"

RSpec.describe "Jobs", type: :request do
  let(:user) { create(:user, is_admin: false) }


  context "contributor" do
    before { sign_in(user) }
    it "cannot access the Jobs interface" do
      get "/jobs"
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include("Access denied")
    end
  end

  context "administrator" do
    before do
      sign_in(user)
        user.update(is_admin: true)
    end

    it "can access the Jobs interface" do
      get "/jobs"
      expect(response).to be_successful
    end
  end

  context "not authenticated" do
    it "redirects to the login page" do
      get "/jobs"
      expect(response).to redirect_to("/session/new")
      expect(session[:return_to_after_authenticating]).to end_with("/jobs/")
    end
  end
end
