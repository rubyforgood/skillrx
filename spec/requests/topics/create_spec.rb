require "rails_helper"

describe "Topics", type: :request do
  describe "POST /topics" do
    let(:user) { create(:user) }
    let(:provider) { create(:provider) }
    let(:language) { create(:language) }
    let(:topic_params) { attributes_for(:topic, provider_id: provider.id, language_id: language.id) }

    before { sign_in(user) }

    it "creates a Topic" do
      post topics_url, params: { topic: topic_params }

      expect(response).to redirect_to(topics_url)
      topic = Topic.last
      expect(topic.title).to eq("topic")
      expect(topic.description).to eq("details")
      expect(topic.state).to eq("active")
    end
  end
end
