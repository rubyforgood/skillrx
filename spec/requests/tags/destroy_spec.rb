require "rails_helper"

describe "Tags", type: :request do
  describe "DELETE /tags/:id" do
    let(:user) { create(:user, :admin) }
    let(:tag) { create(:tag) }

    before { sign_in(user) }

    it "deletes a Tag" do
      delete tag_url(tag)

      expect(response).to redirect_to(tags_url)
      expect(Tag.count).to be_zero
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it "does not delete a Tag" do
        delete tag_url(tag)

        expect(response).to redirect_to(tags_url)
        expect(Tag.count).to eq(1)
      end
    end
  end
end
