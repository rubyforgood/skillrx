require "rails_helper"

# Jobs (the Mission Control Jobs engine) renders inside the SkillRx shell, with the design
# system's tabs, instead of the engine's own Bulma layout in a new tab.
# layouts/mission_control/jobs/application.html.erb; docs/design/decisions.md, 2026-11-26.
RSpec.describe "Jobs", type: :request do
  let(:admin) { create(:user, :admin) }

  before { sign_in(admin) }

  it "renders in the app shell, with Jobs current in the rail" do
    get "/jobs"

    expect(response).to be_successful
    page = Capybara.string(response.body)
    expect(page).to have_css("aside.shell-rail a.shell-nav-link[aria-current='page']", text: "Jobs")
    expect(page).to have_css("main#main-content h1", text: "Jobs", count: 1)
    expect(page).to have_no_css("a[target='_blank']", text: "Jobs")
  end

  it "keeps the engine's ?server_id out of the app's own links" do
    get "/jobs"

    rail = Capybara.string(response.body).find("aside.shell-rail")
    expect(rail.all("a").map { _1[:href] }).to all(satisfy { |href| !href.include?("server_id") })
  end

  it "shows the engine's sections as page tabs in sentence case, with the current one marked" do
    get "/jobs"

    tabs = Capybara.string(response.body).find("rfg-page-tabs[label='Job sections']")
    expect(tabs).to have_css("a[aria-current='page']", text: "Queues", count: 1)
    # Sentence case: no capital after the first letter ("In progress jobs", not "In Progress jobs").
    # The test queue adapter has fewer sections than Solid Queue, so check every one shown.
    expect(tabs.all("a").map(&:text)).to all(match(/\A[A-Z][^A-Z]*\z/))
  end

  it "doesn't load Bulma or the engine's importmap" do
    get "/jobs"

    expect(response.body).not_to include("bulma")
    expect(response.body).not_to include("mission_control/jobs/application")
  end

  it "titles the page after the section" do
    get "/jobs"

    expect(Capybara.string(response.body)).to have_title("Queues · Jobs")
  end
end
