require "rails_helper"

RSpec.describe "Editing a Topic", type: :system do
  let(:user) { create(:user, email: "me@mail.com", password: "test123") }
  let(:provider) { create(:provider) }
  let(:language) { create(:language) }
  let!(:topic) { create(:topic, provider:, language:) }

  before do
    provider.users << user
    login_as(user)
  end

  it "updates a Topic" do
    wait_and_visit(edit_topic_path(topic))
    expect(page).to have_button("Update Topic")

    select 2024, from: "topic_published_at_year"
    select 3, from: "topic_published_at_month"
    click_button "Update Topic"
    expect(page).to have_content(topic.title)
    expect(Topic.count).to eq(1)
    expect(Topic.first.published_at).to eq(Date.new(2024, 3, 1))
  end

  describe "when removing a tag" do
    let(:tag) { create(:tag, name: "Tag to remove") }

    before do
      topic.set_tag_list_on(topic.language.code.to_sym, tag.name)
      topic.save
    end

    context "when the tag is not used on any other topic" do
      it "removes the tag from the topic and destroys the unused tag" do
        wait_and_visit edit_topic_path(topic)
        expect(page).to have_content(topic.current_tags.first.name)
        find('[aria-label="Clear"]').click
        click_button "Update Topic"
        wait_and_visit topic_path(topic)
        expect(page).not_to have_text(tag.name)
        expect(Tag.find_by(name: tag.name)).to be_nil
      end
    end

    context "when the tag is still used on an other topic" do
      let(:topic_2) { create(:topic, provider:, language:) }

      before do
        topic_2.set_tag_list_on(topic.language.code.to_sym, tag.name)
        topic_2.save
      end

      it "removes the tag from the topic but does not destroy the tag" do
        wait_and_visit edit_topic_path(topic)
        expect(page).to have_content(topic.current_tags.first.name)
        find('[aria-label="Clear"]').click
        click_button "Update Topic"
        wait_and_visit topic_path(topic)
        expect(page).not_to have_text(tag.name)
        expect(Tag.find_by(name: tag.name)).to be_present
      end
    end
  end

  describe "when removing a tag whose cognate remains associated to the Topic" do
    let(:tag) { create(:tag, name: "Tag to remove") }
    let(:cognate) { create(:tag, name: "Cognate to keep") }

    before do
      tag.cognates << cognate
      topic.set_tag_list_on(topic.language.code.to_sym, "#{tag.name},#{cognate.name}")
      topic.save
    end

    it "removes the tag but keeps the cognate" do
      wait_and_visit edit_topic_path(topic)

      first('[aria-label="Clear"]').click
      click_button "Update Topic"

      wait_and_visit topic_path(topic)
      expect(page).to have_text(cognate.name)
      expect(page).not_to have_text(tag.name)
      expect(Tag.find_by(name: tag.name)).to be_nil
    end
  end
end
