require "rails_helper"

describe "Tags", type: :request do
  describe "GET /api/v1/tags" do
    let(:language) { create(:language) }
    let(:topic) { create(:topic, language: language) }
    let(:tag) { create(:tag) }
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it "renders a successful response" do
      tag_topic(topic, tag)

      get api_v1_tags_url, params: { language_id: topic.language.id }

      expect(response).to be_successful
      expect(assigns(:tags)).to eq([ tag ])
    end

    it " renders a unsuccessful response" do
      get api_v1_tags_url

      expect(response).not_to be_successful
    end
  end

  private

  def tag_topic(topic, tag)
    topic.set_tag_list_on(topic.language_code, tag.name)
    topic.save
  end
end
