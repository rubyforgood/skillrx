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

    it "enqueues SynchronizeCognatesOnTopicsJob" do
      put tag_url(tag), params: { tag: tag_params }
      expect(SynchronizeCognatesOnTopicsJob).to have_been_enqueued.with(tag)
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

    context "when adding a cognate on a tag that already had a cognate" do
      let(:cardio_tag) { create(:tag, name: "Cardio") }
      let(:cardiovascular_tag) { create(:tag, name: "Cardiovascular") }
      let(:cardiac_tag) { create(:tag, name: "Cardiac") }
      let(:tag_params) { attributes_for(:tag, name: "Heart", cognates_list: [ "", "Cardio", "Cardiovascular", "Cardiac" ]) }

      before do
        create(:tag_cognate, tag: tag, cognate: cardio_tag)
        create(:tag_cognate, tag: cardio_tag, cognate: cardiovascular_tag)
        create(:tag_cognate, tag: cardiovascular_tag, cognate: tag)
      end

      it "associates the new cognate to the tag and the old cognate" do
        expect { put tag_url(tag), params: { tag: tag_params } }
          .to change { tag.reload.cognates_list }
          .from([ "Cardio", "Cardiovascular" ]).to(match_array([ "Cardio", "Cardiovascular", "Cardiac" ]))
          .and change { cardiac_tag.reload.cognates_list }
          .from([]).to(match_array([ "Heart", "Cardio", "Cardiovascular" ]))
          .and change { cardiovascular_tag.reload.cognates_list }
          .from([ "Hart", "Cardio" ]).to(match_array([ "Heart", "Cardio", "Cardiac" ]))
          .and change { cardio_tag.reload.cognates_list }
          .from([ "Hart", "Cardiovascular" ]).to(match_array([ "Heart", "Cardiovascular", "Cardiac" ]))
      end
    end

    context "when adding as cognate a tag that already has a cognate" do
      let(:cardiovascular_tag) { create(:tag, name: "Cardiovascular") }
      let(:cardio_tag) { create(:tag, name: "Cardio") }
      let(:tag_params) { attributes_for(:tag, name: "Heart", cognates_list: [ "", "Cardio" ]) }

      before do
        create(:tag_cognate, tag: cardiovascular_tag, cognate: cardio_tag)
      end

      it "associates the tag with the cognates of the cognate" do
        expect { put tag_url(tag), params: { tag: tag_params } }
          .to change { tag.reload.cognates_list }
          .from([]).to(match_array([ "Cardio", "Cardiovascular" ]))
          .and change { cardiovascular_tag.reload.cognates_list }
          .from([ "Cardio" ]).to(match_array([ "Heart", "Cardio" ]))
      end
    end

    context "when part of the cognates are being removed" do
      let(:cardiovascular_tag) { create(:tag, name: "Cardiovascular") }
      let(:cardio_tag) { create(:tag, name: "Cardio") }
      let(:circulatory_tag) { create(:tag, name: "Circulatory") }
      let(:tag_params) { attributes_for(:tag, name: "Heart", cognates_list: [ "", "Cardio" ]) }

      before do
        create(:tag_cognate, tag: tag, cognate: cardiovascular_tag)
        create(:tag_cognate, tag: tag, cognate: cardio_tag)
        create(:tag_cognate, tag: circulatory_tag, cognate: tag)
        create(:tag_cognate, tag: cardiovascular_tag, cognate: cardio_tag)
        create(:tag_cognate, tag: cardiovascular_tag, cognate: circulatory_tag)
        create(:tag_cognate, tag: circulatory_tag, cognate: cardio_tag)
      end

      it "removes the association to the removed cognates" do
        expect { put tag_url(tag), params: { tag: tag_params } }
          .to change { tag.reload.cognates_list }
          .from([ "Cardiovascular", "Cardio", "Circulatory" ]).to([ "Cardio" ])

        cardiovascular_tag = Tag.find_by(name: "Cardiovascular")
        cardio_tag = Tag.find_by(name: "Cardio")
        circulatory_tag = Tag.find_by(name: "Circulatory")
        expect(cardiovascular_tag).not_to be_nil
        expect(cardiovascular_tag.cognates_list).to be_empty
        expect(cardio_tag.cognates_list).to match_array([ "Heart" ])
        expect(circulatory_tag).not_to be_nil
        expect(circulatory_tag.cognates_list).to be_empty
      end
    end

    context "when all cognates are being removed" do
      let(:cardiovascular_tag) { create(:tag, name: "Cardiovascular") }
      let(:cardio_tag) { create(:tag, name: "Cardio") }
      let(:tag_params) { attributes_for(:tag, name: "Heart", cognates_list: [ "" ]) }

      before do
        create(:tag_cognate, tag: tag, cognate: cardiovascular_tag)
        create(:tag_cognate, tag: tag, cognate: cardio_tag)
        create(:tag_cognate, tag: cardiovascular_tag, cognate: cardio_tag)
      end

      it "removes the associations with the removed cognates" do
        expect { put tag_url(tag), params: { tag: tag_params } }
          .to change { tag.reload.cognates_list }
          .from(match_array([ "Cardiovascular", "Cardio" ])).to([])

        cardiovascular_tag = Tag.find_by(name: "Cardiovascular")
        cardio_tag = Tag.find_by(name: "Cardio")
        expect(cardiovascular_tag).not_to be_nil
        expect(cardiovascular_tag.cognates_list).to be_empty
        expect(cardio_tag).not_to be_nil
        expect(cardio_tag.cognates_list).to be_empty
      end

      it "does not enqueue SynchronizeCognatesOnTopicsJob" do
        put tag_url(tag), params: { tag: tag_params }
        expect(SynchronizeCognatesOnTopicsJob).not_to have_been_enqueued.with(tag)
      end
    end
  end
end
