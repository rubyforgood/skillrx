require "rails_helper"

describe "Tags", type: :request do
  describe "DELETE /tags/:id" do
    let(:user) { create(:user, :admin) }
    let(:tag) { create(:tag) }
    let(:turbo_stream_headers) { { Accept: "text/vnd.turbo-stream.html" } }

    before { sign_in(user) }

    context "when requesting deletion confirmation" do
      it "renders turbo stream to confirm deletion" do
        delete tag_url(tag), headers: turbo_stream_headers

        expect(Tag.count).to be 1
        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      end
    end

    context "when deletion is confirmed" do
      it "deletes a Tag" do
        delete tag_url(tag, confirmed: true)

        expect(response).to redirect_to(tags_url)
        expect(Tag.count).to be_zero
      end
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it "preserves the tag and redirects" do
        delete tag_url(tag)

        expect(response).to redirect_to(tags_url)
        expect(Tag.count).to eq(1)
      end
    end
  end
end
