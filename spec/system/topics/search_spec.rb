require "rails_helper"

RSpec.describe "Topics search", type: :system do
  let(:english) { create(:language, name: "English") }
  let(:spanish) { create(:language, name: "Spanish") }
  let(:tag_name) { create(:language, name: "basic").name }
  let(:provider_1) { create(:provider) }
  let(:provider_2) { create(:provider) }
  let!(:spanish_active_topic) do
    create(
      :topic,
      language: spanish,
      title: "Tratamiento del resfriado",
      created_at: Date.new(2025, 02, 03),
      published_at: Date.new(2025, 02, 03),
      provider: provider_1
    )
  end
  let!(:english_active_topic) do
    create(
      :topic,
      language: english,
      title: "How to treat colds",
      description: "All the latest information about nasopharyngitis",
      created_at: Date.new(2025, 03, 04),
      published_at: Date.new(2025, 03, 04),
      provider: provider_1
    )
  end
  let!(:english_archived_topic) do
    create(
      :topic,
      :archived,
      language: english,
      title: "Obsolete",
      created_at: Date.new(2023, 02, 01),
      published_at: Date.new(2023, 02, 01),
      provider: provider_1
    )
  end
  let!(:other_provider_topic) do
    create(
      :topic,
      language: english,
      title: "Other provider topic",
      provider: provider_2
    )
  end

  let!(:english_topic_tagged) do
    english_active_topic.set_tag_list_on(english.code.to_sym, tag_name)
    english_active_topic.save
    english_active_topic.reload
  end

  before do
    login_as(user)
  end

  context "when the user is an admin" do
    let(:user) { create(:user, :admin, email: "admin@mail.com") }

    before { click_link("Topics") }

    it "shows all topics from first provider" do
      expect(page).to have_text(english_active_topic.title)
      expect(page).to have_text(spanish_active_topic.title)
      expect(page).to have_text(english_archived_topic.title)
    end

    context "when searching by title" do
      it "only displays topics matching the search" do
        fill_in "search_query", with: "tratamiento"

        expect(page).to have_text(spanish_active_topic.title)
        expect(page).not_to have_text(english_active_topic.title)
        expect(page).not_to have_text(english_archived_topic.title)
      end
    end

    context "when searching by description" do
      it "only displays topics matching the search" do
        fill_in "search_query", with: "pharyn"

        expect(page).to have_text(english_active_topic.title)
        expect(page).not_to have_text(spanish_active_topic.title)
        expect(page).not_to have_text(english_archived_topic.title)
      end
    end

    context "when searching by language" do
      it "only displays topics matching the search" do
        select "Spanish", from: "search_language_id"

        expect(page).to have_text(spanish_active_topic.title)
        expect(page).not_to have_text(english_active_topic.title)
        expect(page).not_to have_text(english_archived_topic.title)

        select "English", from: "search_language_id"

        expect(page).to have_text(english_active_topic.title)
        expect(page).to have_text(english_archived_topic.title)
        expect(page).not_to have_text(spanish_active_topic.title)
      end
    end

    context "when searching by year" do
      it "only displays topics matching the search" do
        select "2025", from: "search_year"

        expect(page).to have_text(spanish_active_topic.title)
        expect(page).to have_text(english_active_topic.title)
        expect(page).not_to have_text(english_archived_topic.title)

        select "2023", from: "search_year"

        expect(page).to have_text(english_archived_topic.title)
        expect(page).not_to have_text(spanish_active_topic.title)
        expect(page).not_to have_text(english_active_topic.title)
      end
    end

    context "when searching by month" do
      it "only displays topics matching the search" do
        select "2", from: "search_month"

        expect(page).to have_text(spanish_active_topic.title)
        expect(page).to have_text(english_archived_topic.title)
        expect(page).not_to have_text(english_active_topic.title)

        select "3", from: "search_month"

        expect(page).to have_text(english_active_topic.title)
        expect(page).not_to have_text(english_archived_topic.title)
        expect(page).not_to have_text(spanish_active_topic.title)
      end
    end

    context "when searching by state" do
      it "only displays topics matching the search" do
        select "active", from: "search_state"

        expect(page).to have_text(spanish_active_topic.title)
        expect(page).to have_text(english_active_topic.title)
        expect(page).not_to have_text(english_archived_topic.title)

        select "archived", from: "search_state"

        expect(page).to have_text(english_archived_topic.title)
        expect(page).not_to have_text(spanish_active_topic.title)
        expect(page).not_to have_text(english_active_topic.title)
      end
    end

    context "when searching by tags" do
      it "only displays topics matching the search" do
        choose_tag(tag_name)

        expect(page).to have_text(english_topic_tagged.title)
        expect(page).not_to have_text(spanish_active_topic.title)
        expect(page).not_to have_text(english_archived_topic.title)
      end
    end

    context "when sorting" do
      it "displays users in the selected order" do
        select "asc", from: "search_order"
        expect(page).to have_text(/#{english_archived_topic.title}.+#{spanish_active_topic.title}.+#{english_active_topic.title}/m)
      end
    end

    context "when switching to another provider" do
      it "only shows topics from the selected provider" do
        select provider_2.name, from: "provider_id"
        expect(page).to have_text(other_provider_topic.title)
        expect(page).not_to have_text(english_active_topic.title)
        expect(page).not_to have_text(spanish_active_topic.title)
        expect(page).not_to have_text(english_archived_topic.title)
      end
    end
  end

  context "when the user is a contributor" do
    let(:user) { create(:user) }

    context "with 1 associated provider" do
      before do
        user.update(provider_ids: [ provider_1.id ])
        click_link("Topics")
      end

      it "doesn't have a dropdown menu to change the provider" do
        expect(page).not_to have_select("provider_id")
      end

      it "only shows topics from its first associated provider" do
        expect(page).to have_text(english_active_topic.title)
        expect(page).to have_text(spanish_active_topic.title)
        expect(page).to have_text(english_archived_topic.title)
        expect(page).not_to have_text(other_provider_topic.title)
      end

      context "when searching by title" do
        it "only displays topics matching the search" do
          fill_in "search_query", with: "tratamiento"

          expect(page).to have_text(spanish_active_topic.title)
          expect(page).not_to have_text(english_active_topic.title)
          expect(page).not_to have_text(english_archived_topic.title)
        end
      end

      context "when searching by description" do
        it "only displays topics matching the search" do
          fill_in "search_query", with: "pharyn"

          expect(page).to have_text(english_active_topic.title)
          expect(page).not_to have_text(spanish_active_topic.title)
          expect(page).not_to have_text(english_archived_topic.title)
        end
      end

      context "when searching by language" do
        it "only displays topics matching the search" do
          select "Spanish", from: "search_language_id"

          expect(page).to have_text(spanish_active_topic.title)
          expect(page).not_to have_text(english_active_topic.title)
          expect(page).not_to have_text(english_archived_topic.title)

          select "English", from: "search_language_id"

          expect(page).to have_text(english_active_topic.title)
          expect(page).to have_text(english_archived_topic.title)
          expect(page).not_to have_text(spanish_active_topic.title)
        end
      end

      context "when searching by year" do
        it "only displays topics matching the search" do
          select "2025", from: "search_year"

          expect(page).to have_text(spanish_active_topic.title)
          expect(page).to have_text(english_active_topic.title)
          expect(page).not_to have_text(english_archived_topic.title)

          select "2023", from: "search_year"

          expect(page).to have_text(english_archived_topic.title)
          expect(page).not_to have_text(spanish_active_topic.title)
          expect(page).not_to have_text(english_active_topic.title)
        end
      end

      context "when searching by month" do
        it "only displays topics matching the search" do
          select "2", from: "search_month"

          expect(page).to have_text(spanish_active_topic.title)
          expect(page).to have_text(english_archived_topic.title)
          expect(page).not_to have_text(english_active_topic.title)

          select "3", from: "search_month"

          expect(page).to have_text(english_active_topic.title)
          expect(page).not_to have_text(english_archived_topic.title)
          expect(page).not_to have_text(spanish_active_topic.title)
        end
      end

      context "when searching by state" do
        it "only displays topics matching the search" do
          select "active", from: "search_state"

          expect(page).to have_text(spanish_active_topic.title)
          expect(page).to have_text(english_active_topic.title)
          expect(page).not_to have_text(english_archived_topic.title)

          select "archived", from: "search_state"

          expect(page).to have_text(english_archived_topic.title)
          expect(page).not_to have_text(spanish_active_topic.title)
          expect(page).not_to have_text(english_active_topic.title)
        end
      end

      context "when searching by tags" do
        it "only displays topics matching the search" do
          choose_tag(tag_name)

          expect(page).to have_text(english_topic_tagged.title)
          expect(page).not_to have_text(spanish_active_topic.title)
          expect(page).not_to have_text(english_archived_topic.title)
        end
      end

      context "when sorting" do
        it "displays users in the selected order" do
          select "asc", from: "search_order"
          expect(page).to have_text(/#{english_archived_topic.title}.+#{spanish_active_topic.title}.+#{english_active_topic.title}/m)
        end
      end
    end

    context "with multiple associated providers" do
      before do
        user.update(provider_ids: [ provider_1.id, provider_2.id ])
        click_link("Topics")
      end

      it "only shows topics from its first associated provider" do
        expect(page).to have_text(english_active_topic.title)
        expect(page).to have_text(spanish_active_topic.title)
        expect(page).to have_text(english_archived_topic.title)
        expect(page).not_to have_text(other_provider_topic.title)
      end

      context "when switching to another provider" do
        it "only shows topics from the selected provider" do
          select provider_2.name, from: "provider_id"
          expect(page).to have_text(other_provider_topic.title)
          expect(page).not_to have_text(english_active_topic.title)
          expect(page).not_to have_text(spanish_active_topic.title)
          expect(page).not_to have_text(english_archived_topic.title)
        end
      end
    end
  end
end
