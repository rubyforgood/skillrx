require "rails_helper"

RSpec.describe "Topics", type: :request do
  let(:user) { create(:user) }
  let(:provider) { create(:provider) }
  let(:language) { create(:language) }
  let!(:topic) { create(:topic, provider: provider, language: language) }

  before { sign_in(user) }

  describe "PUT /topics/:id" do
    context "when removing a tag" do
      let!(:tag) { create(:tag, name: "Tag to remove") }

      before do
        topic.set_tag_list_on(topic.language.code.to_sym, tag.name)
        topic.save
      end

      context "when the tag is not used on any other topic" do
        let(:topic_params) {  { tag_list: [ "" ] } }

        it "removes the tag from the topic and destroys the unused tag" do
          put topic_url(topic), params: { topic: topic_params }
          expect(response).to redirect_to(topics_url)
          expect(topic.reload.current_tags).to be_empty
          expect(Tag.find_by(name: tag.name)).to be_nil
        end
      end

      context "when the tag is still used on another topic" do
        let!(:topic_2) { create(:topic, provider: provider, language: language) }
        let(:topic_params) {  { tag_list: [ "" ] } }

        before do
          topic_2.set_tag_list_on(topic.language.code.to_sym, tag.name)
          topic_2.save
        end

        it "removes the tag from the topic but does not destroy the tag" do
          put topic_url(topic), params: { topic: topic_params }
          expect(response).to redirect_to(topics_url)
          expect(topic.reload.current_tags).to be_empty
          expect(Tag.find_by(name: tag.name)).to be_present
        end
      end
    end

    context "when removing a tag whose cognate remains associated to the Topic" do
      let!(:tag) { create(:tag, name: "Tag to remove") }
      let!(:cognate) { create(:tag, name: "Cognate to keep") }
      let(:topic_params) {  { tag_list: [ cognate.name ] } }

      before do
        tag.cognates << cognate
        topic.set_tag_list_on(topic.language.code.to_sym, "#{tag.name},#{cognate.name}")
        topic.save
      end

      it "removes the tag but keeps the cognate" do
        put topic_url(topic), params: { topic: topic_params }
        expect(response).to redirect_to(topics_url)
        expect(topic.reload.current_tags).to eq([ cognate ])
        expect(Tag.find_by(name: tag.name)).to be_nil
      end
    end
  end
end
