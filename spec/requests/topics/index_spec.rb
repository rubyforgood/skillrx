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

    it "displays the number of documents" do
      topic = create(:topic, :with_documents, provider:)

      get topics_url

      expect(page).to have_css("td", text: "1")
    end

    it "displays published and added dates without description or UID columns" do
      create(
        :topic,
        provider:,
        published_at: Time.zone.local(2021, 1, 1),
        created_at: Time.zone.local(2022, 2, 2)
      )

      get topics_url

      expect(page).to have_css("th", text: "Published")
      expect(page).to have_css("th", text: "Added")
      expect(page).to have_css("td", text: "Jan 01, 2021")
      expect(page).to have_css("td", text: "Feb 02, 2022")
      expect(page).not_to have_css("th", text: "Description")
      expect(page).not_to have_css("th", text: "UID")

      added_link = page.find_link("Added")
      expect(added_link[:href]).to include("search%5Bsort%5D=created_at", "search%5Border%5D=desc")
      expect(added_link["data-turbo-frame"]).to eq("_top")
      expect(page).to have_css("th:not(.hide-mobile)", text: "Published")
      expect(page).to have_css("th:not(.hide-mobile)", text: "Added")
    end

    it "sorts topics by the selected column and direction" do
      newer_topic = create(:topic, provider:, title: "Newer", created_at: Time.zone.local(2022, 1, 1))
      older_topic = create(:topic, provider:, title: "Older", created_at: Time.zone.local(2021, 1, 1))

      get topics_url, params: { search: { state: "active", sort: "created_at", order: "asc" } }

      expect(assigns(:topics)).to eq([ older_topic, newer_topic ])
      expect(page).to have_css("input[type='hidden'][name='search[sort]'][value='created_at']", visible: :all)
      expect(page).to have_select("search_order", selected: "asc")
      expect(page).to have_css("th[aria-sort='ascending']", text: "Added")
    end

    it "falls back to published date for an unsupported sort column" do
      older_topic = create(:topic, provider:, published_at: Time.zone.local(2021, 1, 1))
      newer_topic = create(:topic, provider:, published_at: Time.zone.local(2022, 1, 1))

      get topics_url, params: { search: { state: "active", sort: "uid", order: "asc" } }

      expect(assigns(:topics)).to eq([ older_topic, newer_topic ])
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
          create(:topic, provider:, state: :archived)

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
          topic = create(:topic, provider:, published_at: Time.zone.local(2021, 1, 1))

          get topics_url, params: { search: { year: 2021, month: 1 } }

          expect(response).to be_successful
          expect(assigns(:topics)).to eq([ topic ])
        end
      end
    end
  end
end
