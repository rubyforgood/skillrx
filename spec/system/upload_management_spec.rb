require "rails_helper"

RSpec.describe "Upload Management", type: :system do
  let(:admin) { create(:user, :admin, email: "admin@mail.com") }

  before do
    login_as(admin)
  end

  context "when creating a new topic" do
    before { wait_and_visit(new_topic_path) }

    it "shows added documents" do
      page.attach_file(Rails.root.join("test/fixtures/images/logo_ruby_for_good.png")) do
        page.find("#documents").click
      end
      expect(page).to have_text("logo_ruby_for_good.png")
    end

    it "deletes added documents" do
      page.attach_file(Rails.root.join("test/fixtures/images/logo_ruby_for_good.png")) do
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
        io: File.open(Rails.root.join("test/fixtures/images/logo_ruby_for_good.png")),
        filename: "logo_ruby_for_good.png",
        content_type: "image/png"
      )
      wait_and_visit edit_topic_path(topic)
    end

    context "when adding a document" do
      it "does not replace pre-existing documents" do
        expect(page).to have_text("logo_ruby_for_good.png")
        page.attach_file(Rails.root.join("test/fixtures/images/skillrx_sidebar.png")) do
          page.find("#documents").click
        end
        expect(page).to have_text("logo_ruby_for_good.png")
        expect(page).to have_text("skillrx_sidebar.png")
        click_button("Update Topic")
        click_link("View", href: topic_path(topic))
        expect(page).to have_text("skillrx_sidebar.png")
      end

      context "when the user does not confirm the addition of files" do
        it "does not add the document" do
          expect(page).to have_text("logo_ruby_for_good.png")
          page.attach_file(Rails.root.join("test/fixtures/images/skillrx_sidebar.png")) do
            page.find("#documents").click
          end
          expect(page).to have_text("logo_ruby_for_good.png")
          expect(page).to have_text("skillrx_sidebar.png")
          click_link("Cancel")
          click_link("View", href: topic_path(topic))
          expect(page).to have_text("logo_ruby_for_good.png")
          expect(page).not_to have_text("skillrx_sidebar.png")
        end
      end

      context "with an unsupported file type" do
        it "does not add the document" do
          expect(page).to have_text("logo_ruby_for_good.png")
          page.attach_file(Rails.root.join("test/fixtures/files/file_text_test.txt")) do
            page.find("#documents").click
          end
          expect(page).to have_text("logo_ruby_for_good.png")
          expect(page).to have_text("file_text_test.txt")
          click_button("Update Topic")
          expect(page).to have_text("View")
          click_link("View", href: topic_path(topic))
          expect(page).not_to have_text("file_text_test.txt")
        end
      end
    end

    context "when removing a document" do
      it "removes the document" do
        expect(page).to have_text("logo_ruby_for_good.png")
        click_button("remove-button-1")
        expect(page).not_to have_text("logo_ruby_for_good.png")
        click_button("Update Topic")
        expect(page).to have_text("View")
        click_link("View", href: topic_path(topic))
        expect(page).not_to have_text("logo_ruby_for_good.png")
      end

      context "when the user does not confirm the deletion" do
        it "does not remove the document" do
          expect(page).to have_text("logo_ruby_for_good.png")
          click_button("remove-button-1")
          expect(page).not_to have_text("logo_ruby_for_good.png")
          click_link("Cancel")
          expect(page).to have_text("View")
          click_link("View", href: topic_path(topic))
          expect(page).to have_text("logo_ruby_for_good.png")
        end
      end
    end
  end
end
