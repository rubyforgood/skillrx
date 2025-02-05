require "rails_helper"

describe "Topics", type: :request do
  describe "DELETE /topics/:id" do
    let(:user) { create(:user, :admin) }
    let(:topic) { create(:topic) }

    before { sign_in(user) }

    it "deletes a Topic" do
      delete topic_url(topic)

      expect(response).to redirect_to(topics_url)
      expect(Topic.count).to be_zero
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it "does not delete a Topic" do
        delete topic_url(topic)

        expect(response).to redirect_to(topics_url)
        expect(Topic.count).to eq(1)
      end
    end
  end
end
