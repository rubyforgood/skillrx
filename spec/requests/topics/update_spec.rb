require "rails_helper"

describe "Topics", type: :request do
  describe "PUT /topics/:id" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it "updates a Language" do
      topic = create(:topic)
      topic_params = { title: "new topic", description: "updated" }

      put topic_url(topic), params: { topic: topic_params }

      topic.reload
      expect(response).to redirect_to(topics_url)
      expect(topic.title).to eq("new topic")
      expect(topic.description).to eq("updated")
    end
  end
end
