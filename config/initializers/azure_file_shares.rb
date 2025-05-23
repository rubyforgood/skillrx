require "dotenv"
require "logger"

Dotenv.load(".env") if Rails.env.local?

AzureFileShares.configure do |config|
  # logger = Logger.new(STDOUT)
  # logger.level = Logger::DEBUG
  # config.logger = logger
  config.storage_account_name = ENV["AZURE_STORAGE_ACCOUNT_NAME"]
  config.storage_account_key = ENV["AZURE_STORAGE_ACCOUNT_KEY"]
  config.api_version = ENV["AZURE_API_VERSION"] || "2025-05-05"
end
