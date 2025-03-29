require "rails_helper"

describe "Tags", type: :request do
  describe "POST /tags" do
    let(:user) { create(:user) }
    let(:tag_params) { attributes_for(:tag, name: "Ruby") }

    before do
      sign_in(user)
    end

    it "creates a Tag" do
      post tags_url, params: { tag: tag_params }

      expect(response).to redirect_to(tags_url)
      tag = Tag.last
      expect(tag.name).to eq("Ruby")
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
