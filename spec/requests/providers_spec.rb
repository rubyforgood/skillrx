require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/providers", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  let(:region_ids) { [create(:region).id, create(:region).id] }
  let(:updated_region_ids) { [create(:region).id] }
  # This should return the minimal set of attributes required to create a valid
  # Provider. As you add validations to Provider, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { name: "MyString", provider_type: "MyString", region_ids: region_ids }
  }

  let(:invalid_attributes) {
    { name: "", provider_type: "" }
  }

  describe "GET /index" do
    it "renders a successful response" do
      Provider.create! valid_attributes
      get providers_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      provider = Provider.create! valid_attributes
      get provider_url(provider)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_provider_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      provider = Provider.create! valid_attributes
      get edit_provider_url(provider)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Provider" do
        expect {
          post providers_url, params: { provider: valid_attributes }
        }.to change(Provider, :count).by(1)
      end

      it "creates two new Branches" do
        expect {
          post providers_url, params: { provider: valid_attributes }
        }.to change(Branch, :count).by(2)
      end

      it "redirects to the created provider" do
        post providers_url, params: { provider: valid_attributes }
        expect(response).to redirect_to(provider_url(Provider.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Provider" do
        expect {
          post providers_url, params: { provider: invalid_attributes }
        }.to change(Provider, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post providers_url, params: { provider: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { name: "MyString", provider_type: "MyType", region_ids: updated_region_ids }
      }

      it "updates the requested provider" do
        provider = Provider.create! valid_attributes
        patch provider_url(provider), params: { provider: new_attributes }
        provider.reload
        expect(provider.name).to eq("MyString")
        expect(provider.provider_type).to eq("MyType")
        expect(provider.regions.length).to eq(updated_region_ids.length)
      end

      it "redirects to the provider" do
        provider = Provider.create! valid_attributes
        patch provider_url(provider), params: { provider: new_attributes }
        provider.reload
        expect(response).to redirect_to(provider_url(provider))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        provider = Provider.create! valid_attributes
        patch provider_url(provider), params: { provider: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested provider" do
      provider = Provider.create! valid_attributes
      expect {
        delete provider_url(provider)
      }.to change(Provider, :count).by(-1)
    end

    it "redirects to the providers list" do
      provider = Provider.create! valid_attributes
      delete provider_url(provider)
      expect(response).to redirect_to(providers_url)
    end
  end
end
