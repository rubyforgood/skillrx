require "rails_helper"

RSpec.describe "/topics", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  let(:valid_attributes) { { title: "New Topic", description: "Topic description", language_id: 1, provider_id: 1, archived: false } }
  let(:invalid_attributes) { { title: "", language_id: nil, provider_id: nil } }

  describe "GET /index" do
    it "renders a successful response" do
      topic = FactoryBot.create(:topic)
      get topics_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      topic = FactoryBot.create(:topic)
      get topic_url(topic)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_topic_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      topic = FactoryBot.create(:topic)
      get edit_topic_url(topic)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Topic" do
        expect {
          post topics_url, params: { topic: valid_attributes }
        }.to change(Topic, :count).by(1)
      end

      it "redirects to the created topic" do
        post topics_url, params: { topic: valid_attributes }
        expect(response).to redirect_to(topic_url(Topic.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new Topic" do
        expect {
          post topics_url, params: { topic: invalid_attributes }
        }.to change(Topic, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post topics_url, params: { topic: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) { { title: "Updated Topic", description: "Updated description" } }

      it "updates the requested topic" do
        topic = Topic.create! valid_attributes
        patch topic_url(topic), params: { topic: new_attributes }
        topic.reload
        expect(topic.title).to eq("Updated Topic")
        expect(topic.description).to eq("Updated description")
      end

      it "redirects to the topic" do
        topic = Topic.create! valid_attributes
        patch topic_url(topic), params: { topic: new_attributes }
        topic.reload
        expect(response).to redirect_to(topic_url(topic))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        topic = Topic.create! valid_attributes
        patch topic_url(topic), params: { topic: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested topic" do
      topic = Topic.create! valid_attributes
      expect {
        delete topic_url(topic)
      }.to change(Topic, :count).by(-1)
    end

    it "redirects to the topics list" do
      topic = Topic.create! valid_attributes
      delete topic_url(topic)
      expect(response).to redirect_to(topics_url)
    end
  end
end
