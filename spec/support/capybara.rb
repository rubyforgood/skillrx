require "capybara/rails"
require "capybara/rspec"
require "selenium/webdriver"

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :debug, type: :system) do
    driven_by :selenium_chrome
  end
end
