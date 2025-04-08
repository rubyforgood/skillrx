require "rails_helper"

describe "Tags", type: :request do
  describe "POST /tags" do
    let(:user) { create(:user) }
    let(:tag_params) { attributes_for(:tag, name: "Lisp", cognates_list: [ "Common Lisp" ]) }

    before do
      sign_in(user)
    end

    it "creates a Tag" do
      post tags_url, params: { tag: tag_params }

      expect(response).to redirect_to(tags_url)
      tag = Tag.last
      expect(tag.name).to eq("Lisp")
      expect(tag.cognates_list).to eq([ "Common Lisp" ])
    end

    context "when user is an admin" do
      before { user.update(is_admin: true) }

      it "creates a Tag" do
        post tags_url, params: { tag: tag_params.merge(name: "Perl") }

        expect(response).to redirect_to(tags_url)
        tag = Tag.last
        expect(tag.name).to eq("Perl")
      end
    end
  end
end
