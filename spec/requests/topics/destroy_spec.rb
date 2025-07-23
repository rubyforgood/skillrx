require "rails_helper"

describe "Topics", type: :request do
  describe "DELETE /topics/:id" do
    let(:user) { create(:user, :admin) }
    let!(:topic) { create(:topic) }
    let(:turbo_stream_headers) { { Accept: "text/vnd.turbo-stream.html" } }

    before { sign_in(user) }

    context "when first clickin on the Delete button" do
      it "renders turbo stream to confirm deletion" do
        expect { delete topic_url(topic), headers: turbo_stream_headers }
        .not_to change(Topic, :count)

        expect(response).to have_http_status(:ok)
        expect(response.media_type).to eq "text/vnd.turbo-stream.html"
      end
    end

    context "when deletion has been confirmed by the admin" do
      it "deletes a Topic" do
        delete topic_url(topic, confirmed: true)

        expect(response).to redirect_to(topics_url)
        expect(Topic.count).to be_zero
      end

      it "displays a success message" do
        delete topic_url(topic, confirmed: true)

        expect(flash[:notice]).to eq("Topic was successfully destroyed.")
      end

      context "when topic has documents" do
        let(:topic) { create(:topic, :with_documents) }

        before do
          allow(DocumentsSyncJob).to receive(:perform_later)
        end

        it "runs sync job for documents" do
          delete topic_url(topic, confirmed: true)

          expect(response).to redirect_to(topics_url)
          expect(DocumentsSyncJob).to have_received(:perform_later).with(hash_including(action: "delete"))
        end
      end
    end

    context "when user is not an admin" do
      let(:user) { create(:user) }

      it "does not delete a Topic" do
        delete topic_url(topic)

        expect(response).to redirect_to(topics_url)
        expect(Topic.count).to eq(1)
      end
    end
  end
end
