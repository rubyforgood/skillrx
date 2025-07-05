source "https://rubygems.org"

ruby "3.4.1"

gem "active_storage_validations"
gem "acts-as-taggable-on"
gem "aws-sdk-s3", require: false
gem "azure_file_shares", github: "dmitrytrager/azure_file_shares"
gem "bcrypt", "~> 3.1.7"
gem "bootsnap", require: false
gem "csv"
gem "image_processing", "~> 1.14"
gem "importmap-rails"
gem "jbuilder"
gem "kamal", require: false
gem "pagy"
gem "pg", "~> 1.1"
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.0.1"
gem "requestjs-rails"
gem "scout_apm"
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
gem "solid_queue_monitor", "~> 0.3.2"
gem "stimulus-rails"
gem "thruster", require: false
gem "turbo-rails"

gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "brakeman", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "annotaterb"
  gem "bullet"
  gem "hotwire-spark"
  gem "letter_opener"
  gem "rack-mini-profiler"
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "database_cleaner"
  gem "rails-controller-testing"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
end
