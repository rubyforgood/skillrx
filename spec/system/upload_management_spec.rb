require "rails_helper"

RSpec.describe "Upload Management", type: :system do
  let(:admin) { create(:user, :admin, email: "admin@mail.com") }

  before do
    login_as(admin)
  end

  context "when creating a new topic" do
    before { visit_with_wait(new_topic_path) }

    it "shows added documents" do
      page.attach_file(Rails.root.join("spec/support/images/logo_ruby_for_good.png")) do
        page.find("#documents").click
      end
      expect(page).to have_text("logo_ruby_for_good.png")
    end

    it "deletes added documents" do
      page.attach_file(Rails.root.join("spec/support/images/logo_ruby_for_good.png")) do
        page.find("#documents").click
      end
      expect(page).to have_text("logo_ruby_for_good.png")
      click_button("remove-button-1")
      expect(page).not_to have_text("logo_ruby_for_good.png")
    end
  end

  context "when updating a topic " do
    let(:topic) { create(:topic) }

    before do
      topic.documents.attach(
        io: File.open(Rails.root.join("spec/support/images/logo_ruby_for_good.png")),
        filename: "logo_ruby_for_good.png",
        content_type: "image/png"
      )
      visit edit_topic_path(topic)
    end

    context "when adding a document" do
      it "doesn't replace pre-existing documents" do
        expect(page).to have_text("logo_ruby_for_good.png")
        page.attach_file(Rails.root.join("test/fixtures/files/file_text_test.txt")) do
          page.find("#documents").click
        end
        expect(page).to have_text("logo_ruby_for_good.png")
        expect(page).to have_text("file_text_test.txt")
      end
    end

    context "when removing a document" do
      it "removes the document" do
        expect(page).to have_text("logo_ruby_for_good.png")
        click_button("remove-button-1")
        expect(page).not_to have_text("logo_ruby_for_good.png")
        click_button("Update Topic")
        # This checks we are redirected to Topic#index instead of re-rendering the form
        expect(page).to have_text("Search")
      end
    end
  end
end
