require "rails_helper"

RSpec.describe "Dashboards", type: :request do
  describe "GET /dashboard/index" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it "displays the dashboard" do
      get "/dashboard/index"
      expect(page).to have_text("Welcome to your dashboard")
    end
  end
end
