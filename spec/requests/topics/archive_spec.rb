require "rails_helper"

describe "Topics", type: :request do
  describe "PUT /topics/:id" do
    let(:user) { create(:user) }
    let(:topic) { create(:topic) }

    before { sign_in(user) }

    it "archives a Topic" do
      put archive_topic_url(topic)

      expect(response).to redirect_to(topics_url)
      expect(topic.reload.state).to eq("archived")
    end
  end
end
