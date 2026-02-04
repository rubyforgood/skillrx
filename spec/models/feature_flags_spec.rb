require "rails_helper"

RSpec.describe FeatureFlags do
  after { Current.feature_overrides = nil }

  describe ".enabled?" do
    context "with request-scoped override" do
      it "returns true when flag is overridden to true" do
        described_class.enable!(:beacons)

        expect(described_class.enabled?(:beacons)).to be true
      end

      it "returns false when flag is overridden to false" do
        described_class.disable!(:beacons)

        expect(described_class.enabled?(:beacons)).to be false
      end

      it "takes precedence over credentials" do
        allow(Rails.application.credentials).to receive(:dig)
          .with(:features, :beacons).and_return(true)

        described_class.disable!(:beacons)

        expect(described_class.enabled?(:beacons)).to be false
      end
    end

    context "with ENV override" do
      it "returns true when ENV is set to true" do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("FEATURE_BEACONS").and_return("true")

        expect(described_class.enabled?(:beacons)).to be true
      end

      it "returns false when ENV is set to false" do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("FEATURE_BEACONS").and_return("false")

        expect(described_class.enabled?(:beacons)).to be false
      end
    end

    context "with boolean credential" do
      it "returns true when credential is true" do
        allow(Rails.application.credentials).to receive(:dig)
          .with(:features, :my_flag).and_return(true)

        expect(described_class.enabled?(:my_flag)).to be true
      end

      it "returns false when credential is false" do
        allow(Rails.application.credentials).to receive(:dig)
          .with(:features, :my_flag).and_return(false)

        expect(described_class.enabled?(:my_flag)).to be false
      end
    end

    context "with hash credential and allowed_emails" do
      before do
        allow(Rails.application.credentials).to receive(:dig)
          .with(:features, :beacons)
          .and_return({ enabled: false, allowed_emails: [ "admin@skillrx.org" ] })
      end

      it "returns true for a user whose email is allowed" do
        user = build(:user, email: "admin@skillrx.org")

        expect(described_class.enabled?(:beacons, user: user)).to be true
      end

      it "returns false for a user whose email is not allowed" do
        user = build(:user, email: "other@example.com")

        expect(described_class.enabled?(:beacons, user: user)).to be false
      end

      it "returns false when no user is provided" do
        expect(described_class.enabled?(:beacons)).to be false
      end
    end

    context "with globally enabled hash credential" do
      before do
        allow(Rails.application.credentials).to receive(:dig)
          .with(:features, :beacons)
          .and_return({ enabled: true, allowed_emails: [ "admin@skillrx.org" ] })
      end

      it "returns true regardless of user" do
        expect(described_class.enabled?(:beacons)).to be true
      end
    end

    context "with unknown flag" do
      it "returns false" do
        allow(Rails.application.credentials).to receive(:dig)
          .with(:features, :unknown).and_return(nil)

        expect(described_class.enabled?(:unknown)).to be false
      end
    end
  end

  describe ".disabled?" do
    it "returns the inverse of enabled?" do
      allow(Rails.application.credentials).to receive(:dig)
        .with(:features, :beacons).and_return(true)

      expect(described_class.disabled?(:beacons)).to be false
    end
  end

  describe ".with" do
    it "enables the flag within the block" do
      value_inside = nil

      described_class.with(:beacons, true) do
        value_inside = described_class.enabled?(:beacons)
      end

      expect(value_inside).to be true
      expect(described_class.enabled?(:beacons)).to be false
    end

    it "disables the flag within the block" do
      described_class.enable!(:beacons)

      value_inside = nil
      described_class.with(:beacons, false) do
        value_inside = described_class.enabled?(:beacons)
      end

      expect(value_inside).to be false
      expect(described_class.enabled?(:beacons)).to be true
    end

    it "restores the previous override after the block" do
      described_class.enable!(:beacons)

      described_class.with(:beacons, false) { }

      expect(Current.feature_overrides[:beacons]).to be true
    end
  end
end
