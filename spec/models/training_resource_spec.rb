require "rails_helper"

RSpec.describe TrainingResource, type: :model do
  subject { create(:training_resource) }
  it { should validate_presence_of(:state) }
  it { should have_one_attached(:document) }

  it "should reject creation of resources with duplicated filenames within the same language" do
    resource = create(:training_resource, file_name_override: "filename.pdf")
    expect {
      create(:training_resource, file_name_override: "filename.pdf", topic_id: resource.topic_id)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it "should allow creation of resources without file_name_override" do
    expect {
      create(:training_resource, file_name_override: nil)
    }.to change(TrainingResource, :count).by(1)
  end
end
