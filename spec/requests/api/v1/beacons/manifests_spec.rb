require "rails_helper"

RSpec.describe "Beacons Manifest API", type: :request do
  let(:language) { create(:language, name: "English") }
  let(:region) { create(:region, name: "East Region") }
  let(:provider) { create(:provider, name: "Health Ministry") }

  let(:beacon) do
    b, @raw_key = create_beacon_with_key(language: language, region: region)
    b.providers << provider
    b
  end

  let(:raw_key) { beacon; @raw_key }

  let(:topic) do
    create(:topic, :with_documents, title: "Maternal Health", provider: provider, language: language).tap do |t|
      t.tag_list.add("Prenatal")
      t.save!
      beacon.topics << t
    end
  end

  before { topic }

  describe "GET /api/v1/beacons/manifest" do
    it "returns the full manifest with correct structure" do
      get "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key)

      expect(response).to have_http_status(:ok)

      body = response.parsed_body
      expect(body["manifest_version"]).to eq("v1")
      expect(body["manifest_checksum"]).to start_with("sha256:")
      expect(body["generated_at"]).to be_present
      expect(body["language"]["name"]).to eq("English")
      expect(body["language"]["code"]).to eq("en")
      expect(body["region"]["name"]).to eq("East Region")
      expect(body["tags"].first["name"]).to eq("prenatal")
      expect(body["providers"].first["name"]).to eq("Health Ministry")
      expect(body["providers"].first["topics"].first["name"]).to eq("Maternal Health")
      expect(body["total_files"]).to eq(1)
      expect(body["total_size_bytes"]).to be > 0
    end

    it "returns ETag header with manifest version" do
      get "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key)

      expect(response.headers["ETag"]).to eq("v1")
    end

    it "increments version when content changes" do
      get "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key)
      expect(response.parsed_body["manifest_version"]).to eq("v1")

      new_topic = create(:topic, :with_documents, title: "New Topic", provider: provider, language: language)
      beacon.topics << new_topic

      get "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key)
      expect(response.parsed_body["manifest_version"]).to eq("v2")
      expect(response.headers["ETag"]).to eq("v2")
    end

    it "requires authentication" do
      get "/api/v1/beacons/manifest"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "HEAD /api/v1/beacons/manifest" do
    context "with If-None-Match" do
      it "returns 304 when ETag matches current version" do
        get "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key)
        etag = response.headers["ETag"]

        head "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key).merge("If-None-Match" => etag)

        expect(response).to have_http_status(:not_modified)
        expect(response.headers["ETag"]).to eq(etag)
      end

      it "returns 200 when ETag does not match current version" do
        get "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key)

        head "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key).merge("If-None-Match" => "v999")

        expect(response).to have_http_status(:ok)
        expect(response.headers["ETag"]).to be_present
      end
    end

    context "with If-Match" do
      it "returns 200 when ETag matches current version" do
        get "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key)
        etag = response.headers["ETag"]

        head "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key).merge("If-Match" => etag)

        expect(response).to have_http_status(:ok)
        expect(response.headers["ETag"]).to eq(etag)
      end

      it "returns 412 when ETag does not match current version" do
        get "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key)
        etag = response.headers["ETag"]

        head "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key).merge("If-Match" => "v999")

        expect(response).to have_http_status(:precondition_failed)
        expect(response.headers["ETag"]).to eq(etag)
      end
    end

    context "using stored beacon version" do
      it "returns 304 without a prior GET when beacon version is pre-set" do
        beacon.update!(manifest_version: 5, manifest_checksum: "sha256:precomputed")

        head "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key).merge("If-None-Match" => "v5")

        expect(response).to have_http_status(:not_modified)
        expect(response.headers["ETag"]).to eq("v5")
      end

      it "returns 412 without a prior GET when beacon version is pre-set" do
        beacon.update!(manifest_version: 5, manifest_checksum: "sha256:precomputed")

        head "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key).merge("If-Match" => "v3")

        expect(response).to have_http_status(:precondition_failed)
        expect(response.headers["ETag"]).to eq("v5")
      end

      it "does not build the manifest for 304 responses" do
        beacon.update!(manifest_version: 5, manifest_checksum: "sha256:precomputed")

        expect(Beacons::ManifestBuilder).not_to receive(:new)

        head "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key).merge("If-None-Match" => "v5")

        expect(response).to have_http_status(:not_modified)
      end

      it "does not build the manifest for 412 responses" do
        beacon.update!(manifest_version: 5, manifest_checksum: "sha256:precomputed")

        expect(Beacons::ManifestBuilder).not_to receive(:new)

        head "/api/v1/beacons/manifest", headers: beacon_auth_headers(raw_key).merge("If-Match" => "v3")

        expect(response).to have_http_status(:precondition_failed)
      end
    end
  end
end
