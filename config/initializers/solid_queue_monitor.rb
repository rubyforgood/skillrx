# frozen_string_literal: true

SolidQueueMonitor.setup do |config|
  # Enable or disable authentication
  # When disabled, no authentication is required to access the monitor
  config.authentication_enabled = true

  # Set the username for HTTP Basic Authentication (only used if authentication is enabled)
  config.username = ENV["SOLID_QUEUE_MONITOR_USERNAME"] || "admin"

  # Set the password for HTTP Basic Authentication (only used if authentication is enabled)
  config.password = ENV["SOLID_QUEUE_MONITOR_PASSWORD"] || "test"

  # Number of jobs to display per page
  # config.jobs_per_page = 25
end
