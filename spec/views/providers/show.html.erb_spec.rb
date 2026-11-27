require "rails_helper"

RSpec.describe "providers/show", type: :view do
  before(:each) do
    assign(:provider, Provider.create!(
      name: "Name",
      provider_type: "Provider Type",
    ),)
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Provider Type/)
  end

  # docs/design/design.md, "Record pages": one column, row metadata as a quiet line, not a card.
  it "shows the type once, links the topic count, and puts row metadata in one line" do
    render
    expect(rendered.scan("Provider Type").size).to eq(1)
    expect(rendered).to have_link("0 topics", href: topics_path(provider: Provider.last.id, search: { state: "" }))
    expect(rendered).not_to have_css("h2", text: "Record")
    expect(rendered).to have_css(".record-meta", text: /Added .+ Last updated .+ ID #{Provider.last.id}/m)
  end
end
