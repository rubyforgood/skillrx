require "rails_helper"

RSpec.describe "Upload Management", type: :system do
  let(:admin) { create(:user, :admin, email: "admin@mail.com") }


  before do
    login_as(admin)
    click_link("Topics")
  end


  context "When create new Topic" do
    it "show added documents" do
      click_link("Add New Topic")
        page.attach_file(Rails.root.join("spec/support/images/logo_ruby_for_good.png")) do
        page.find("#documents").click
      end
      click_button("upload")
      expect(page).to have_text("logo_ruby_for_good.png")
    end


    it "deletes added documents" do
      click_link("Add New Topic")
      page.attach_file(Rails.root.join("spec/support/images/logo_ruby_for_good.png")) do
        page.find("#documents").click
      end
      click_button("upload")
      expect(page).to have_text("logo_ruby_for_good.png")
      click_button("remove-button")
      expect(page).not_to have_text("logo_ruby_for_good.png")
    end
  end


  context "When update Topic " do
    let!(:topic) { create(:topic) }
    before do
      topic.documents.attach(
        io: File.open(Rails.root.join("spec/support/images/logo_ruby_for_good.png")),
        filename: "logo_ruby_for_good.png",
        content_type: "image/png"
      )
    end
    it "Doesn't replace documents" do
      click_link("Edit")
      expect(page).to have_text("logo_ruby_for_good.png")
      page.attach_file(Rails.root.join("spec/support/files/file_text_test.txt")) do
        page.find("#documents").click
      end
      click_button("upload")
      expect(page).to have_text("logo_ruby_for_good.png")
      expect(page).to have_text("file_text_test.txt")
    end
  end
end
