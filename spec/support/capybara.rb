require "capybara/rails"
require "capybara/rspec"
require "selenium/webdriver"

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :selenium_chrome_headless do |app|
  chrome_flags =  %w[headless disable-gpu window-size=1400,1400]

  if ENV["DOCKER_CONTAINER"]
    chrome_flags.concat(%w[no-sandbox disable-dev-shm-usage])
  end

  options = Selenium::WebDriver::Chrome::Options.new(args: chrome_flags)
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

module CapybaraPage
  def page
    Capybara.string(response.body)
  end
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :selenium_chrome_headless
  end

  config.before(:each, :debug, type: :system) do
    driven_by :selenium_chrome
  end

  config.include CapybaraPage, type: :request
end
