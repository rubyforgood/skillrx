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

    context "Tag-related actions" do
      let!(:tag) { create(:tag) }

      it "cannot access the Tags index" do
        expect(get "/tags").to redirect_to(topics_path)
      end

      it "cannot access Tag show page" do
        expect(get "/tags/#{tag.id}").to redirect_to(topics_path)
      end

      it "cannot access Tag edit page" do
        expect(get "/tags/#{tag.id}/edit").to redirect_to(topics_path)
      end

      it "cannot make a Tag update request" do
        expect { put "/tags/#{tag.id}", params: { tag: { name: "Updated Tag" } } }.not_to change { tag.reload.updated_at }
        expect(response).to redirect_to(topics_path)
      end

      it "cannot make a Tag delete request" do
        expect(delete "/tags/#{tag.id}").to redirect_to(topics_path)
      end
    end

    it "cannot access the Users tab" do
      get "/users"
      expect(response).to redirect_to(topics_path)
    end

    context "Import Reports-related actions" do
      let!(:import_report) { ImportReport.create }

      it "cannot access the ImportReport index" do
        expect(get "/import_reports").to redirect_to(topics_path)
      end

      it "cannot access ImportReport show page" do
        expect(get "/import_reports/#{import_report.id}").to redirect_to(topics_path)
      end
    end
  end

  context "administrator" do
    before { user.update(is_admin: true) }

    it "can access the Topics tab" do
      get "/topics"
      expect(response).to be_successful
    end

    it "can access the Regions tab" do
      get "/regions"
      expect(response).to be_successful
    end

    it "can access the Providers tab" do
      get "/providers"
      expect(response).to be_successful
    end

    it "can access the Languages tab" do
      get "/languages"
      expect(response).to be_successful
    end

    it "can access the Users tab" do
      get "/users"
      expect(response).to be_successful
    end
  end
end
