require "rails_helper"

RSpec.describe "Creating a Topic", type: :system do
  describe "there is a create topic button" do
    let!(:english) { create(:language, name: "English") }
    let!(:provider) { create(:provider) }

    before do
      login_as(user)
      click_link("Topics")
      click_link("Add New Topic")
    end

    context "as an Admin" do
      let(:user) { create(:user, :admin) }

      context "when successful" do
        it "creates a Topic" do
          fill_in "Title", with: "My Topic"
          select "English", from: "topic_language_id"
          select provider.name, from: "topic_provider_id"
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
