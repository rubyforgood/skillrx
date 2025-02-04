require "rails_helper"

RSpec.describe Topic, type: :model do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:language_id) }
  it { should validate_presence_of(:provider_id) }

  it { should belong_to(:language) }
  it { should belong_to(:provider) }
  # it { should have_many(:taggings) }
  # it { should have_many(:training_resources) }

  describe "scopes" do
    it "includes archived topics" do
      archived_topic = create(:topic, archived: true)
      expect(Topic.archived).to include(archived_topic)
    end
  end
end
