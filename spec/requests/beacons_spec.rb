require "rails_helper"

RSpec.describe "/beacons", type: :request do
  let(:user) { create(:user, :admin) }
  let(:region) { create(:region) }
  let(:language) { create(:language) }
  let(:valid_attributes) do
      { name: "New Beacon",
        language_id: language.id,
        region_id: region.id,
      }
  end
  let(:invalid_attributes) { { name: "" } }

  before do
    sign_in(user)
  end

  describe "GET /index" do
    it "renders a successful response" do
      create(:beacon)

      get beacons_url

      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      beacon = create(:beacon)

      get beacon_url(beacon)

      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_beacon_url

      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    let(:beacon) { create(:beacon) }

    it "renders a successful response" do
      get edit_beacon_url(beacon)

      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new beacon" do
        expect {
          post beacons_url, params: { beacon: valid_attributes }
        }.to change(Beacon, :count).by(1)
      end

      it "redirects to the created beacon" do
        post beacons_url, params: { beacon: valid_attributes }

        expect(response).to redirect_to(beacon_url(Beacon.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new beacon" do
        expect {
          post beacons_url, params: { beacon: invalid_attributes }
        }.to change(Beacon, :count).by(0)
      end

      it "renders a response with 422 status (i.e. to display the 'new' template)" do
        post beacons_url, params: { beacon: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:updated_region) { create(:region) }
      let(:updated_language) { create(:language) }
      let(:new_attributes) do
          { name: "Updated Beacon",
            language_id: updated_language.id,
            region_id: updated_region.id,
          }
      end

      it "updates the requested beacon" do
        beacon = create(:beacon)

        patch beacon_url(beacon), params: { beacon: new_attributes }
        beacon.reload

        expect(beacon.name).to eq("Updated Beacon")
        expect(beacon.language).to eq(updated_language)
        expect(beacon.region).to eq(updated_region)
      end

      it "redirects to the beacon" do
        beacon = create(:beacon)

        patch beacon_url(beacon), params: { beacon: new_attributes }
        beacon.reload

        expect(response).to redirect_to(beacon_url(beacon))
      end
    end

    context "with invalid parameters" do
      it "renders a response with 422 status (i.e. to display the 'edit' template)" do
        beacon = create(:beacon)

        patch beacon_url(beacon), params: { beacon: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "POST /regenerate_key" do
    subject { post regenerate_key_beacon_url(beacon) }

    it "regenerates the API key for the requested beacon" do
      beacon = create(:beacon)

      expect { subject }.to change { beacon.api_key_digest }
        .and change { beacon.api_key_prefix }
    end

    it "redirects to the beacon" do
      beacon = create(:beacon)

      subject

      expect(response).to redirect_to(beacon_url(beacon))
    end

    context "when there is an error" do
      allow(Beacon).to receive(:regenerate).raise_error

      it "does not regenerate the API key for the requested beacon" do
        beacon = create(:beacon)

        expect { subject }.not_to change { beacon.api_key_digest }
          .and change { beacon.api_key_prefix }
      end

      it "redirects to the beacon" do
        beacon = create(:beacon)

        subject

        expect(response).to redirect_to(beacon_url(beacon))
      end
    end
  end

  describe "POST /revoke_key" do
    include ActiveSupport::Testing::TimeHelpers
    subject { post revoke_key_beacon_url(beacon) }

    it "redirects to the beacon" do
      beacon = create(:beacon)

      subject

      expect(response).to redirect_to(beacon_url(beacon))
    end

    context "when there is an error" do
      allow(Beacon).to receive(:regenerate).raise_error

      it "redirects to the beacon" do
        beacon = create(:beacon)

        subject

        expect(response).to redirect_to(beacon_url(beacon))
      end
    end
  end
end
