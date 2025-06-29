require "rails_helper"

describe "Tags", type: :request do
  describe "POST /tags" do
    let(:user) { create(:user) }
    let(:tag_params) { attributes_for(:tag, name: "Heart", cognates_list: [ "", "Cardiovascular", "Cardio" ]) }

    before do
      sign_in(user)
    end

    it "creates a Tag and its cognates" do
      expect { post tags_url, params: { tag: tag_params } }.to change(Tag, :count).by(3)

      expect(response).to redirect_to(tags_url)
      heart_tag = Tag.find_by(name: "Heart")
      cardiovascular_tag = Tag.find_by(name: "Cardiovascular")
      cardio_tag = Tag.find_by(name: "Cardio")

      expect(heart_tag.cognates_list).to match_array([ "Cardiovascular", "Cardio" ])
      expect(cardiovascular_tag.cognates_list).to match_array([ "Heart", "Cardio" ])
      expect(cardio_tag.cognates_list).to match_array([ "Heart", "Cardiovascular" ])
    end

    context "when the same tag is passed twice as cognate" do
      let(:tag_params) { attributes_for(:tag, name: "Heart", cognates_list: [ "", "Heart", "Cardiovascular", "Cardio", "Cardio" ]) }

      it "creates a Tag and only non-duplicate cognates" do
        expect { post tags_url, params: { tag: tag_params } }.to change(Tag, :count).by(3)

        expect(response).to redirect_to(tags_url)
        heart_tag = Tag.find_by(name: "Heart")
        cardiovascular_tag = Tag.find_by(name: "Cardiovascular")
        cardio_tag = Tag.find_by(name: "Cardio")

        expect(heart_tag.cognates_list).to match_array([ "Cardiovascular", "Cardio" ])
        expect(cardiovascular_tag.cognates_list).to match_array([ "Heart", "Cardio" ])
        expect(cardio_tag.cognates_list).to match_array([ "Heart", "Cardiovascular" ])
      end
    end
  end
end
