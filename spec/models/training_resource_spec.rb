require "rails_helper"

RSpec.describe TrainingResource, type: :model do
  it { should validate_presence_of(:state) }
  it { should have_one_attached(:document) }
end
