require "rails_helper"

RSpec.describe "/users", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:provider_1) { create(:provider) }
  let(:provider_2) { create(:provider) }
  let(:valid_attributes) do
      { email: "new_name@example.com",
        password: "new_password",
        provider_ids: [ provider_1.id, provider_2.id ],
      }
  end
  let(:invalid_attributes) { { email: "" } }

  before do
    sign_in(admin)
  end

  describe "GET /index" do
    it "renders a successful response" do
      get users_url

      expect(response).to be_successful
    end

    it "has a link to add a new user" do
      get users_url

      expect(page).to have_link("Add New User", href: new_user_path)
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_user_url

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:user) { User.last }

      it "creates a new user with correct attributes and associations" do
        expect {
          post users_url, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
        expect(user.email).to eq("new_name@example.com")
        expect(user.password_digest).not_to be_nil
        expect(user.provider_ids).to match_array([ provider_1.id, provider_2.id ])
        expect(user.is_admin).to be_falsey
      end

      it "redirects to the user index" do
        post users_url, params: { user: valid_attributes }

        expect(response).to redirect_to(users_path)
      end
    end

    context "with invalid parameters" do
      it "does not create a new User" do
        expect {
          post users_url, params: { user: invalid_attributes }
        }.to change(User, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post users_url, params: { user: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when having no providers" do
      it "does not allow creating a user without providers" do
        expect {
          post users_url, params: { user: valid_attributes.merge(provider_ids: []) }
        }.to change(User, :count).by(0)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      context "when user is admin" do
        it "allows creating a user without providers" do
          expect {
            post users_url, params: { user: valid_attributes.merge(provider_ids: [], is_admin: true) }
          }.to change(User, :count).by(1)
          expect(response).to have_http_status(:redirect)
        end
      end
    end
  end

  describe "GET /edit" do
    let(:user) { create(:user) }

    it "renders a successful response" do
      get edit_user_url(user)

      expect(response).to be_successful
    end
  end

  describe "PATCH /update" do
    let(:user) { create(:user, email: "old_name@example.com", password: "old_password") }

    context "with valid parameters" do
      it "changes the user's attributes" do
        expect { patch user_url(user), params: { user: valid_attributes } }
          .to change { user.reload.email }.from("old_name@example.com").to("new_name@example.com")
          .and change { user.reload.password_digest }
          .and change { user.provider_ids }.to(array_including([ provider_1.id, provider_2.id ]))
      end

      it "redirects to the user" do
        patch user_url(user), params: { user: valid_attributes }

        expect(response).to redirect_to(users_url)
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        patch user_url(user), params: { user: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(page).to have_text("Email can't be blank")
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:user) { create(:user, valid_attributes) }

    it "destroys the requested user" do
      expect {
        delete user_url(user)
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      delete user_url(user)

      expect(response).to redirect_to(users_url)
    end
  end
end
