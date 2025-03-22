require "capybara/rails"
require "capybara/rspec"
require "selenium/webdriver"

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new(args: %w[headless disable-gpu window-size=1400,1400])

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
