require "rails_helper"

RSpec.describe "Jobs", type: :request do
  let(:user) { create(:user, is_admin: false) }

  before { sign_in(user) }

  context "contributor" do
    it "cannot access the Jobs interface" do
      get "/jobs"
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include("Access denied")
    end
  end

  context "administrator" do
    before { user.update(is_admin: true) }

    it "can access the Jobs interface" do
      get "/jobs"
      expect(response).to be_successful
    end
  end
end
