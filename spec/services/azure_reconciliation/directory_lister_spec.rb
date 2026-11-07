require "rails_helper"

RSpec.describe AzureReconciliation::DirectoryLister do
  subject(:lister) { described_class.new(share: "contentshare", files:, connection:) }

  let(:files) do
    double(
      "AzureFileShares::Operations::FileOperations",
      file_base_url: "https://acct.file.core.windows.net",
      client: double(api_version: "2025-05-05"),
    )
  end
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) { Faraday.new { |f| f.adapter :test, stubs } }

  before do
    allow(files).to receive(:calculate_authorization_header).and_return("SharedKey acct:sig")
  end

  def page(names, next_marker: nil)
    entries = names.map do |name, size|
      "<File><Name>#{name}</Name><Properties><Content-Length>#{size}</Content-Length></Properties></File>"
    end.join
    <<~XML
      <?xml version="1.0" encoding="utf-8"?>
      <EnumerationResults><Entries>#{entries}<Directory><Name>sub</Name><Properties /></Directory></Entries>
      <NextMarker>#{next_marker}</NextMarker></EnumerationResults>
    XML
  end

  it "follows the next marker until every page is read" do
    stubs.get("/contentshare/CMES-Pi/assets/Content") do |env|
      if env.params["marker"] == "page2"
        [ 200, {}, page({ "2_b.pdf" => 20 }) ]
      else
        [ 200, {}, page({ "1_a.pdf" => 10 }, next_marker: "page2") ]
      end
    end

    expect(lister.files_in("CMES-Pi/assets/Content")).to eq(
      "1_a.pdf" => 10,
      "2_b.pdf" => 20,
    )
  end

  it "signs the marker as part of the query" do
    stubs.get("/contentshare/Content") { [ 200, {}, page({}) ] }

    lister.files_in("Content")

    expect(files).to have_received(:calculate_authorization_header)
      .with(:get, "/contentshare/Content", hash_including("x-ms-version" => "2025-05-05"), hash_including(comp: "list", restype: "directory"))
  end

  it "returns nil when the directory does not exist" do
    stubs.get("/contentshare/ES_CMES-Pi_Archive") { [ 404, {}, "" ] }

    expect(lister.files_in("ES_CMES-Pi_Archive")).to be_nil
  end

  it "raises on other errors" do
    stubs.get("/contentshare/Content") { [ 500, {}, "boom" ] }

    expect { lister.files_in("Content") }.to raise_error(AzureReconciliation::DirectoryLister::Error, /500/)
  end

  it "includes Azure's authentication detail when the signature is rejected" do
    body = <<~XML
      <?xml version="1.0" encoding="utf-8"?><Error><Code>AuthenticationFailed</Code>
      <Message>Server failed to authenticate the request.#{' padding' * 60}</Message>
      <AuthenticationErrorDetail>Server used following string to sign: 'GET\\n\\n...'</AuthenticationErrorDetail></Error>
    XML
    stubs.get("/contentshare/Content") { [ 403, {}, "\uFEFF#{body}".b ] }

    expect { lister.files_in("Content") }.to raise_error(
      AzureReconciliation::DirectoryLister::Error,
      /403 AuthenticationFailed.*Server used following string to sign/m,
    )
  end
end
