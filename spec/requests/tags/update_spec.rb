require "rails_helper"

describe "Tag", type: :request do
  describe "PUT /tags/:id" do
    let(:user) { create(:user) }
    let!(:tag) { create(:tag, name: "Hart") }
    let(:tag_params) { attributes_for(:tag, name: "Heart", cognates_list: [ "", "Cardiovascular", "Cardio" ]) }


    before { sign_in(user) }

    it "updates a Tag and creates cognates" do
      expect { put tag_url(tag), params: { tag: tag_params } }.to change(Tag, :count).by(2)

      expect(response).to redirect_to(tags_url)
      expect(tag.reload.name).to eq("Heart")
      expect(tag.cognates_list).to match_array([ "Cardiovascular", "Cardio" ])

      cardiovascular_tag = Tag.find_by(name: "Cardiovascular")
      cardio_tag = Tag.find_by(name: "Cardio")
      expect(cardiovascular_tag.cognates_list).to match_array([ "Heart", "Cardio" ])
      expect(cardio_tag.cognates_list).to match_array([ "Heart", "Cardiovascular" ])
    end

    context "when the same tag is passed twice as cognate" do
      let(:tag_params) { attributes_for(:tag, name: "Heart", cognates_list: [ "", "Heart", "Cardiovascular", "Cardio", "Cardio" ]) }

      it "only creates the new cognate" do
        expect { put tag_url(tag), params: { tag: tag_params } }.to change(Tag, :count).by(2)

        expect(tag.reload.cognates_list).to match_array([ "Cardiovascular", "Cardio" ])

        cardiovascular_tag = Tag.find_by(name: "Cardiovascular")
        cardio_tag = Tag.find_by(name: "Cardio")
        expect(cardiovascular_tag.cognates_list).to match_array([ "Heart", "Cardio" ])
        expect(cardio_tag.cognates_list).to match_array([ "Heart", "Cardiovascular" ])
      end
    end
  end
end
