require "rails_helper"

describe "Topics", type: :request do
  describe "GET /topics" do
    let(:provider) { create(:provider) }
    let(:user) { create(:user) }

    before do
      provider.users << user
      sign_in(user)
    end

    it "renders a successful response" do
      topic = create(:topic, provider:)

      get topics_url

      expect(response).to be_successful
      expect(assigns(:topics)).to eq([ topic ])
    end

    describe "searching" do
      context "with a query" do
        it "filters topics by query" do
          topic = create(:topic, provider:, title: "Introduction to English")

          get topics_url, params: { search: { query: "English" } }

          expect(response).to be_successful
          expect(assigns(:topics)).to eq([ topic ])
        end
      end

      context "with a state" do
        it "filters topics by state" do
          active_topic = create(:topic, provider:, state: :active)
          archived_topic = create(:topic, provider:, state: :archived)

          get topics_url, params: { search: { state: "active" } }

          expect(response).to be_successful
          expect(assigns(:topics)).to eq([ active_topic ])
        end
      end

      context "by provider" do
        it "filters topics by provider" do
          topic = create(:topic, provider:)

          get topics_url, params: { search: { provider_id: provider.id } }

          expect(response).to be_successful
          expect(assigns(:topics)).to eq([ topic ])
        end
      end

      context "by language" do
        it "filters topics by language" do
          language = create(:language)
          topic = create(:topic, provider:, language:)

          get topics_url, params: { search: { language_id: language.id } }

          expect(response).to be_successful
          expect(assigns(:topics)).to eq([ topic ])
        end
      end

      context "by year and month" do
        it "filters topics by date" do
          topic = create(:topic, provider:, created_at: Time.zone.local(2021, 1, 1))

          get topics_url, params: { search: { year: 2021, month: 1 } }

          expect(response).to be_successful
          expect(assigns(:topics)).to eq([ topic ])
        end
      end
    end
  end
end
