require "rails_helper"

RSpec.describe "Beacons Files API", type: :request do
  let(:language) { create(:language) }
  let(:region) { create(:region) }
  let(:provider) { create(:provider) }

  let(:beacon_with_key) do
    b, key = create_beacon_with_key(language: language, region: region)
    b.providers << provider
    [ b, key ]
  end

  let(:beacon) { beacon_with_key.first }
  let(:raw_key) { beacon_with_key.last }

  let(:topic) do
    create(:topic, :with_documents, provider: provider, language: language).tap do |t|
      beacon.topics << t
    end
  end

  let(:blob) { topic.documents.first.blob }

  describe "GET /api/v1/beacons/files/:id" do
    context "with valid authentication and access" do
      it "returns the file with correct headers" do
        get "/api/v1/beacons/files/#{blob.id}", headers: beacon_auth_headers(raw_key)

        expect(response).to have_http_status(:ok)
        expect(response.headers["Content-Type"]).to eq(blob.content_type)
        expect(response.headers["Content-Disposition"]).to include("attachment")
        expect(response.headers["Content-Length"]).to eq(blob.byte_size.to_s)
      end

      it "streams the file content" do
        get "/api/v1/beacons/files/#{blob.id}", headers: beacon_auth_headers(raw_key)

        expect(response.body).not_to be_empty
        expect(response.body.bytesize).to eq(blob.byte_size)
      end

      it "includes the filename in Content-Disposition" do
        get "/api/v1/beacons/files/#{blob.id}", headers: beacon_auth_headers(raw_key)

        expect(response.headers["Content-Disposition"]).to include(blob.filename.to_s)
      end
    end

    context "with Range header for resumable downloads" do
      it "returns 206 Partial Content" do
        get "/api/v1/beacons/files/#{blob.id}",
          headers: beacon_auth_headers(raw_key).merge("Range" => "bytes=0-1023")

        expect(response).to have_http_status(:partial_content)
      end

      it "includes Content-Range header" do
        get "/api/v1/beacons/files/#{blob.id}",
          headers: beacon_auth_headers(raw_key).merge("Range" => "bytes=0-1023")

        expect(response.headers["Content-Range"]).to match(/bytes 0-1023\/\d+/)
      end

      it "returns only the requested byte range" do
        get "/api/v1/beacons/files/#{blob.id}",
          headers: beacon_auth_headers(raw_key).merge("Range" => "bytes=0-99")

        expect(response.body.bytesize).to be <= 100
      end
    end

    context "when file does not exist" do
      it "returns 404" do
        get "/api/v1/beacons/files/99999", headers: beacon_auth_headers(raw_key)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when beacon does not have access to the file" do
      let(:other_beacon_with_key) do
        b, k = create_beacon_with_key(language: language, region: region)
        b.providers << provider
        [ b, k ]
      end

      let(:other_beacon) { other_beacon_with_key.first  }
      let(:other_raw_key) { other_beacon_with_key.second }

      let(:other_topic) do
        create(:topic, :with_documents, provider: provider, language: language).tap do |t|
          other_beacon.topics << t
        end
      end

      let(:other_blob) { other_topic.documents.first.blob }

      it "returns 404 when requesting another beacon's file" do
        get "/api/v1/beacons/files/#{other_blob.id}", headers: beacon_auth_headers(raw_key)

        expect(response).to have_http_status(:not_found)
      end
    end

    context "without authentication" do
      it "returns 401" do
        get "/api/v1/beacons/files/#{blob.id}"

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with invalid authentication" do
      it "returns 401" do
        get "/api/v1/beacons/files/#{blob.id}",
          headers: beacon_auth_headers("invalid-key")

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with revoked beacon" do
      before { beacon.revoke! }

      it "returns 401" do
        get "/api/v1/beacons/files/#{blob.id}", headers: beacon_auth_headers(raw_key)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
