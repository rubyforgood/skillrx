require "rails_helper"

RSpec.describe "/users", type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { { email: "john@doe.com", password: "123" } }
  let(:invalid_attributes) { { email: "" } }

  before do
    sign_in(user)
  end

  describe "GET /index" do
    it "renders a successful response" do
      user = FactoryBot.create(:user)
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

  describe "GET /edit" do
    it "renders a successful response" do
      user = FactoryBot.create(:user)
      get edit_user_url(user)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new user" do
        expect {
          post users_url, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
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
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) { { email: "john@doe.com" } }

      it "updates the requested user" do
        user = User.create! valid_attributes
        patch user_url(user), params: { user: new_attributes }
        user.reload
        expect(user.email).to eq("john@doe.com")
      end

      it "redirects to the user" do
        user = User.create! valid_attributes
        patch user_url(user), params: { user: new_attributes }
        user.reload
        expect(response).to redirect_to(users_url)
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        user = User.create! valid_attributes
        patch user_url(user), params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested user" do
      user = User.create! valid_attributes
      expect {
        delete user_url(user)
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      user = User.create! valid_attributes
      delete user_url(user)
      expect(response).to redirect_to(users_url)
    end
  end
end
