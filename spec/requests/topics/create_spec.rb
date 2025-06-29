require "rails_helper"

describe "Topics", type: :request do
  describe "POST /topics" do
    let(:user) { create(:user) }
    let(:provider) { create(:provider) }
    let(:language) { create(:language) }
    let(:topic_params) do
      attributes_for(:topic, title: "topic title", provider_id: provider.id, language_id: language.id).tap do |params|
        params[:published_at_year] = params[:published_at].year
        params[:published_at_month] = params[:published_at].month
        params[:published_at] = nil
      end
    end

    before do
      provider.users << user
      sign_in(user)
    end

    it "creates a Topic" do
      post topics_url, params: { topic: topic_params }

      expect(response).to redirect_to(topics_url)
      topic = Topic.last
      expect(topic.title).to eq("topic title")
      expect(topic.description).to eq("many topic details")
      expect(topic.state).to eq("active")
    end

    context "when user is ad admin" do
      let(:new_provider) { create(:provider) }

      before { user.update(is_admin: true) }

      it "creates a Topic" do
        post topics_url, params: { topic: topic_params.merge(provider_id: new_provider.id) }

        expect(response).to redirect_to(topics_url)
        topic = Topic.last
        expect(topic.provider_id).to eq(new_provider.id)
      end
    end

    context "when current provider is set" do
      let(:current_provider) { create(:provider) }

      before do
        current_provider.users << user
        cookies = ActionDispatch::Request.new(Rails.application.env_config).cookie_jar
        cookies.signed[:current_provider_id] = current_provider.id
      end

      it "creates a Topic for the current provider" do
        post topics_url, params: { topic: topic_params }

        expect(response).to redirect_to(topics_url)
        topic = Topic.last
        expect(topic.provider).to eq(current_provider)
      end

      context "when user is an admin" do
        before { user.update(is_admin: true) }

        it "creates a Topic for the selected provider" do
          post topics_url, params: { topic: topic_params }

          expect(response).to redirect_to(topics_url)
          topic = Topic.last
          expect(topic.provider).to eq(provider)
        end
      end
    end

    context "when topic has documents" do
      let(:blob) do
        ActiveStorage::Blob.create_and_upload!(
          io: File.open(Rails.root.join("spec", "fixtures", "files", "dummy.pdf")),
          filename: "dummy.pdf",
          content_type: "application/pdf",
        )
      end

      before do
        allow(DocumentsSyncJob).to receive(:perform_later)
      end

      it "attaches documents and runs sync job" do
        post topics_url, params: { topic: topic_params.merge(document_signed_ids: [ blob.signed_id ]) }

        expect(response).to redirect_to(topics_url)
        topic = Topic.last
        expect(topic.documents.count).to eq(1)
        expect(topic.documents.first.filename.to_s).to eq("dummy.pdf")
        expect(DocumentsSyncJob).to have_received(:perform_later).with(
          topic_id: topic.id,
          document_id: topic.documents.first.id,
          action: "update",
        )
      end
    end
  end
end
