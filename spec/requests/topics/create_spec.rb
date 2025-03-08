require "rails_helper"

describe "Topics", type: :request do
  describe "POST /topics" do
    let(:user) { create(:user) }
    let(:provider) { create(:provider) }
    let(:language) { create(:language) }
    let(:topic_params) { attributes_for(:topic, provider_id: provider.id, language_id: language.id) }

    before do
      provider.users << user
      sign_in(user)
    end

    it "creates a Topic" do
      post topics_url, params: { topic: topic_params }

      expect(response).to redirect_to(topics_url)
      topic = Topic.last
      expect(topic.title).to eq("topic title")
      expect(topic.description).to eq("many topic details")
      expect(topic.state).to eq("active")
    end

    context "when current provider is set" do
      let(:current_provider) { create(:provider) }

      before do
        current_provider.users << user
        cookies = ActionDispatch::Request.new(Rails.application.env_config).cookie_jar
        cookies.signed[:current_provider_id] = current_provider.id
      end

      it "creates a Topic for the current provider" do
        post topics_url, params: { topic: topic_params }

        expect(response).to redirect_to(topics_url)
        topic = Topic.last
        expect(topic.provider).to eq(current_provider)
      end

      context "when user is an admin" do
        before { user.update(is_admin: true) }

        it "creates a Topic for the selected provider" do
          post topics_url, params: { topic: topic_params }

          expect(response).to redirect_to(topics_url)
          topic = Topic.last
          expect(topic.provider).to eq(provider)
        end
      end
    end
  end
end
