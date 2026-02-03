# == Schema Information
#
# Table name: devices
# Database name: primary
#
#  id             :bigint           not null, primary key
#  api_key_digest :string           not null
#  api_key_prefix :string           not null
#  name           :string           not null
#  revoked_at     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  language_id    :bigint           not null
#
# Indexes
#
#  index_devices_on_api_key_digest  (api_key_digest) UNIQUE
#  index_devices_on_language_id     (language_id)
#
# Foreign Keys
#
#  fk_rails_...  (language_id => languages.id)
#
require "rails_helper"

RSpec.describe Device, type: :model do
  subject { create(:device) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:api_key_digest) }
    it { is_expected.to validate_uniqueness_of(:api_key_digest) }
    it { is_expected.to validate_presence_of(:api_key_prefix) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:language) }
    it { is_expected.to have_many(:device_providers).dependent(:destroy) }
    it { is_expected.to have_many(:providers).through(:device_providers) }
    it { is_expected.to have_many(:device_topics).dependent(:destroy) }
    it { is_expected.to have_many(:topics).through(:device_topics) }
  end

  describe "scopes" do
    let!(:active_device) { create(:device) }
    let!(:revoked_device) { create(:device, :revoked) }

    describe ".active" do
      it "returns only active devices" do
        expect(described_class.active).to contain_exactly(active_device)
      end
    end

    describe ".revoked" do
      it "returns only revoked devices" do
        expect(described_class.revoked).to contain_exactly(revoked_device)
      end
    end
  end

  describe "#revoke!" do
    include ActiveSupport::Testing::TimeHelpers

    it "sets revoked_at to the current time" do
      device = create(:device)
      now = Time.current

      travel_to(now) do
        device.revoke!
        expect(device.revoked_at).to be_within(1.second).of(now)
      end
    end
  end

  describe "#revoked?" do
    it "returns false for active devices" do
      device = create(:device)
      expect(device).not_to be_revoked
    end

    it "returns true for revoked devices" do
      device = create(:device, :revoked)
      expect(device).to be_revoked
    end
  end
end
