# == Schema Information
#
# Table name: providers
# Database name: primary
#
#  id               :bigint           not null, primary key
#  file_name_prefix :string
#  name             :string
#  provider_type    :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  old_id           :integer
#
# Indexes
#
#  index_providers_on_old_id  (old_id) UNIQUE
#
require "rails_helper"

RSpec.describe Provider, type: :model do
  let(:provider) { create(:provider) }
  subject { provider }

  describe "validations" do
    it { should validate_presence_of(:provider_type) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

    describe "#file_name_prefix_may_be_changed" do
      context "when a provider has topics" do
        let!(:topic) { create(:topic, provider: provider) }

        it "returns an error" do
          provider.file_name_prefix = "updated_prefix"
          expect(provider).not_to be_valid
          expect(provider.errors[:file_name_prefix]).to match_array(
            "can't be changed as provider has associated topics and so file names are established"
          )
        end
      end

      context "when a provider has no topics" do
        it "does not return an error" do
          provider.file_name_prefix = "updated_prefix"
          expect(provider).to be_valid
        end
      end
    end
  end

  describe "#topics?" do
    subject { provider.topics? }

    context "when a provider has topics" do
      let!(:topic) { create(:topic, provider: provider) }

      it { is_expected.to be(true) }
    end

    context "when a provider has no topics" do
      it { is_expected.to be(false) }
    end
  end
end
