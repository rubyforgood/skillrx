class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  around_perform do |job, block|
    Rails.logger.debug "[Job Start] #{job.class.name} ID=#{job.job_id}"
    block.call
    Rails.logger.debug "[Job Finish] #{job.class.name} ID=#{job.job_id}"
  rescue => e
    Rails.logger.error "[Job Error] #{job.class.name} ID=#{job.job_id} - #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end
end
