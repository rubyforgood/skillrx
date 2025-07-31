# Use this file to easily define all of your cron jobs.
# Learn more: http://github.com/javan/whenever

# Monitor SolidQueue health every 15 minutes
every 15.minutes do
  rake "solid_queue:monitor"
end

# Clean up stuck jobs every hour  
every 1.hour do
  rake "solid_queue:cleanup"
end

# Example:
# set :output, "/path/to/my/cron_log.log"