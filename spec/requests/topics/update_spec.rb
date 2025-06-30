require "rails_helper"

describe "Topics", type: :request do
  describe "PUT /topics/:id" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic) }

    before { sign_in(user) }

    it "updates the Topic" do
      topic_params = { title: "new topic", description: "updated" }

      expect(put topic_url(topic), params: { topic: topic_params }).to redirect_to(topics_url)
      expect(topic.reload.title).to eq("new topic")
      expect(topic.description).to eq("updated")
    end
  end
end
