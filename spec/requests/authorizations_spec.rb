require "rails_helper"

RSpec.describe "Authorizations", type: :request do
  let(:user) { create(:user) }

  before { sign_in(user) }

  context "contributor" do
    it "can access the Topics tab" do
      get "/topics"
      expect(response).to be_successful
    end

    it "cannot access the Regions tab" do
      get "/regions"
      expect(response).to redirect_to(topics_path)
    end

    it "cannot access the Providers tab" do
      get "/providers"
      expect(response).to redirect_to(topics_path)
    end

    it "cannot access the Languages tab" do
      get "/languages"
      expect(response).to redirect_to(topics_path)
    end

    it "cannot access the Users tab" do
      get "/users"
      expect(response).to redirect_to(topics_path)
    end
  end

  context "administrator" do
    before { user.update(is_admin: true) }

    it "can access the Topics tab" do
      get "/topics"
      expect(response).to be_successful
    end

    it "cannot access the Regions tab" do
      get "/regions"
      expect(response).to be_successful
    end

    it "cannot access the Providers tab" do
      get "/providers"
      expect(response).to be_successful
    end

    it "cannot access the Languages tab" do
      get "/languages"
      expect(response).to be_successful
    end

    it "cannot access the Users tab" do
      get "/users"
      expect(response).to be_successful
    end
  end
end
