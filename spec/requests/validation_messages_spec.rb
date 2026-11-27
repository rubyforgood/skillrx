require "rails_helper"

# Validation messages are designed copy (config/locales/en.yml; docs/design/design.md, "Error
# messages"): each says what to do, once, under its field and in the summary.
RSpec.describe "Validation messages", type: :request do
  let(:admin) { create(:user, :admin) }

  let!(:provider) { create(:provider) }

  before { sign_in(admin) }

  it "tells you what to enter on the topic form, once per field" do
    post topics_path, params: { topic: { title: "", language_id: "", provider_id: provider.id } }

    expect(response).to have_http_status(:unprocessable_content)
    body = Nokogiri::HTML(response.body)
    expect(body.at_css(".error-summary h2").text).to include("Fix these 2 problems to save the topic")
    expect(body.css(".error-summary li").map(&:text)).to eq([ "Enter a title", "Choose a language" ])
    expect(body.at_css("#topic_title_error").text).to eq("Enter a title")
    expect(body.at_css("#topic_language_id_error").text).to eq("Choose a language")
    expect(response.body).not_to include("can't be blank")
    expect(response.body).not_to include("must exist")
  end
end
