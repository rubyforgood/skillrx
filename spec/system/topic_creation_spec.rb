require "rails_helper"

RSpec.describe "Creating a Topic", type: :system do
  describe "there is a create topic button" do
    let!(:english) { create(:language, name: "English") }
    let!(:provider) { create(:provider) }
    let!(:tag_name) { "tag1" }

    before do
      login_as(user)
      wait_and_visit(new_topic_path)
    end

    context "as an Admin" do
      let(:user) { create(:user, :admin) }

      context "when successful" do
        it "creates a Topic" do
          fill_in "Title", with: "My Topic"
          select "English", from: "topic_language_id"
          select provider.name, from: "topic_provider_id"
          select_tag(tag_name)
          click_button("Create Topic")
          expect(page).to have_text("Search")
          expect(page).to have_text("My Topic")

          verify_tags_in_topic_page("My Topic", [ tag_name ])
        end
      end

      context "when failed" do
        it "renders the form with errors" do
          click_button("Create Topic")
          expect(page).to have_text("Title can't be blank")
        end
      end
    end

    context "as a contributor" do
      let(:user) { create(:user) }

      before { provider.users << user }

      context "when successful" do
        it "creates a Topic" do
          fill_in "Title", with: "My Topic"
          select "English", from: "topic_language_id"
          click_button("Create Topic")
          expect(page).to have_text("Search")
          expect(page).to have_text("My Topic")
        end
      end

      context "when failed" do
        it "renders the form with errors" do
          click_button("Create Topic")
          expect(page).to have_text("Title can't be blank")
        end
      end
    end
  end
end
