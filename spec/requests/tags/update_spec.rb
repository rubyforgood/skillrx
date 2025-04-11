require "rails_helper"

describe "Tag", type: :request do
  describe "PUT /tags/:id" do
    let(:user) { create(:user) }

    before { sign_in(user) }

    it "updates a Tag" do
      tag = create(:tag, name: "Java")
      tag_params = { name: "Lisp", cognates_list: [ "Common Lisp" ] }

      put tag_url(tag), params: { tag: tag_params }

      tag.reload
      expect(response).to redirect_to(tags_url)
      expect(tag.name).to eq("Lisp")
      expect(tag.cognates_list).to eq([ "Common Lisp" ])
    end
  end
end
