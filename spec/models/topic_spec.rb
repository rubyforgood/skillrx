# == Schema Information
#
# Table name: topics
#
#  id          :bigint           not null, primary key
#  description :text
#  state       :integer          default("active"), not null
#  title       :string           not null
#  uid         :uuid             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  language_id :bigint
#  old_id      :integer
#  provider_id :bigint
#
# Indexes
#
#  index_topics_on_language_id  (language_id)
#  index_topics_on_old_id       (old_id) UNIQUE
#  index_topics_on_provider_id  (provider_id)
#
require "rails_helper"

RSpec.describe Topic, type: :model do
  subject { create(:topic) }
  
  context "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:language_id) }
    it { should validate_presence_of(:provider_id) }
  end

  context "associations" do
    it { should have_many_attached(:documents) }
  end
end
