module SystemHelpers
  def login_as(user)
    visit new_session_path
    fill_in "Email address", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end

  # Opens the folded "Filters" panel of <rfg-filter-bar>, the way a person would, if it's closed,
  # and waits until `field` is visible. The button is inside two shadow roots (the bar's, then its
  # disclosure's), which Selenium's nested shadow_root finds lose track of, so it's clicked from a
  # script. Retried, because a Turbo visit can swap in a new page (with Filters closed) just after
  # the old one's panel was opened.
  def open_filters(field = "search_language_id")
    # Let any Turbo visit or frame load finish first: Turbo marks them with aria-busy.
    expect(page).to have_no_css("html[aria-busy], turbo-frame[aria-busy]", visible: :all, wait: 5)
    page.document.synchronize(Capybara.default_max_wait_time * 2) do
      page.execute_script(<<~JS)
        const bar = document.querySelector("rfg-filter-bar");
        const d = bar && bar.shadowRoot && bar.shadowRoot.querySelector("rfg-disclosure");
        if (d && !d.open) d.shadowRoot.querySelector("button.trigger").click();
      JS
      raise Capybara::ElementNotFound, "Filters not open" unless page.has_field?(field, visible: true, wait: 0.2)
    end
  end

  # Chooses an option in one of a filter bar's folded filters.
  def select_filter(value, from:)
    open_filters(from)
    select value, from: from
  end

  def wait_and_visit(path)
    sleep(0.5)
    visit path
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
end
