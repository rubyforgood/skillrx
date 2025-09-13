require "rails_helper"

RSpec.describe "Authorizations", type: :request do
  context "not authenticated" do
    context "when trying to access the Regions index" do
      it "redirects to the login page" do
        get "/regions"
        expect(response).to redirect_to("/session/new")
        expect(session[:return_to_after_authenticating]).to eq("/regions")
      end
    end

    context "when trying to access the Providers index" do
      it "redirects to the login page" do
        get "/providers"
        expect(response).to redirect_to("/session/new")
        expect(session[:return_to_after_authenticating]).to eq("/providers")
      end
    end

    context "when trying to access the Languages index" do
      it "redirects to the login page" do
        get "/languages"
        expect(response).to redirect_to("/session/new")
        expect(session[:return_to_after_authenticating]).to eq("/languages")
      end
    end

    context "when trying to access the Tags index" do
      it "redirects to the login page" do
        get "/tags"
        expect(response).to redirect_to("/session/new")
        expect(session[:return_to_after_authenticating]).to eq("/tags")
      end
    end

    context "when trying to access the Users index" do
      it "redirects to the login page" do
        get "/users"
        expect(response).to redirect_to("/session/new")
        expect(session[:return_to_after_authenticating]).to eq("/users")
      end
    end

    context "when trying to access the Import Reports index" do
      it "redirects to the login page" do
        get "/import_reports"
        expect(response).to redirect_to("/session/new")
        expect(session[:return_to_after_authenticating]).to eq("/import_reports")
      end
    end

    context "when trying to access the Jobs interface" do
      it "redirects to the login page" do
        get "/jobs"
        expect(response).to redirect_to("/session/new")
        expect(session[:return_to_after_authenticating]).to eq("/jobs/")
      end
    end
  end

  context "contributor" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it "cannot access the Jobs interface" do
      get "/jobs"
      expect(response).to have_http_status(:forbidden)
      expect(response.body).to include("Access denied")
    end

    context "Region-related actions" do
      let!(:region) { create(:region) }

      it "cannot access the Regions index" do
        expect(get "/regions").to redirect_to(topics_path)
      end

      it "cannot access Region show page" do
        expect(get "/regions/#{region.id}").to redirect_to(topics_path)
      end

      it "cannot access Region new page" do
        expect(get "/regions/new").to redirect_to(topics_path)
      end

      it "cannot make a Region create request" do
        expect { post "/regions", params: { region: { name: "A new Region" } } }.not_to change { Region.count }
        expect(response).to redirect_to(topics_path)
      end

      it "cannot access Region edit page" do
        expect(get "/regions/#{region.id}/edit").to redirect_to(topics_path)
      end

      it "cannot make a Region update request" do
        expect { put "/regions/#{region.id}", params: { region: { name: "Updated Region" } } }.not_to change { region.reload.updated_at }
        expect(response).to redirect_to(topics_path)
      end

      it "cannot make a Region delete request" do
         expect { delete "/regions/#{region.id}" }.not_to change { Region.count }
        expect(response).to redirect_to(topics_path)
      end
    end

    context "Provider-related actions" do
      let!(:provider) { create(:provider) }

      it "cannot access the Providers index" do
        expect(get "/providers").to redirect_to(topics_path)
      end

      it "cannot access Provider show page" do
        expect(get "/providers/#{provider.id}").to redirect_to(topics_path)
      end

      it "cannot access Provider new page" do
        expect(get "/providers/new").to redirect_to(topics_path)
      end

      it "cannot make a Provider create request" do
        expect { post "/providers", params: { provider: { name: "A new Provider", provider_type: "provider" } } }.not_to change { Provider.count }
        expect(response).to redirect_to(topics_path)
      end

      it "cannot access Provider edit page" do
        expect(get "/providers/#{provider.id}/edit").to redirect_to(topics_path)
      end

      it "cannot make a Provider update request" do
        expect { put "/providers/#{provider.id}", params: { provider: { name: "Updated Provider" } } }.not_to change { provider.reload.updated_at }
        expect(response).to redirect_to(topics_path)
      end

      it "cannot make a Provider delete request" do
         expect { delete "/providers/#{provider.id}" }.not_to change { Provider.count }
        expect(response).to redirect_to(topics_path)
      end
    end

    context "Language-related actions" do
      let!(:language) { create(:language) }

      it "cannot access the Languages index" do
        expect(get "/languages").to redirect_to(topics_path)
      end

      it "cannot access Language new page" do
        expect(get "/languages/new").to redirect_to(topics_path)
      end

      it "cannot make a Language create request" do
        expect { post "/languages", params: { language: { name: "A new Language", language_type: "language" } } }.not_to change { Language.count }
        expect(response).to redirect_to(topics_path)
      end

      it "cannot access Language edit page" do
        expect(get "/languages/#{language.id}/edit").to redirect_to(topics_path)
      end

      it "cannot make a Language update request" do
        expect { put "/languages/#{language.id}", params: { language: { name: "Updated Language" } } }.not_to change { language.reload.updated_at }
        expect(response).to redirect_to(topics_path)
      end
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

    context "User-related actions" do
      let!(:user) { create(:user) }

      it "cannot access the Users index" do
        expect(get "/users").to redirect_to(topics_path)
      end

      it "cannot access User new page" do
        expect(get "/users/new").to redirect_to(topics_path)
      end

      it "cannot make a User create request" do
        provider = create(:provider)
        expect { post "/users", params: { user: { email: Faker::Internet.email, password: "password123", provider_ids: [ provider.id ] } } }
          .not_to change { User.count }
        expect(response).to redirect_to(topics_path)
      end

      it "cannot access User edit page" do
        expect(get "/users/#{user.id}/edit").to redirect_to(topics_path)
      end

      it "cannot make a User update request" do
        expect { put "/users/#{user.id}", params: { user: { is_admin: "true" } } }.not_to change { user.reload.updated_at }
        expect(response).to redirect_to(topics_path)
      end

      it "cannot make a User delete request" do
         expect { delete "/users/#{user.id}" }.not_to change { User.count }
        expect(response).to redirect_to(topics_path)
      end
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
    let(:admin) { create(:user, :admin) }

    before { sign_in(admin) }

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

    it "can access the Jobs interface" do
      get "/jobs"
      expect(response).to be_successful
    end
  end
end
