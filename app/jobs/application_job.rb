class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  around_perform do |job, block|
    start_time = Time.current
    Rails.logger.debug "[Job Start] #{job.class.name} ID=#{job.job_id} Args=#{job.arguments}"
    
    block.call
    
    duration = (Time.current - start_time).round(2)
    Rails.logger.debug "[Job Finish] #{job.class.name} ID=#{job.job_id} Duration=#{duration}s"
  rescue => e
    duration = (Time.current - start_time).round(2)
    Rails.logger.error "[Job Error] #{job.class.name} ID=#{job.job_id} Duration=#{duration}s - #{e.class}: #{e.message}"
    Rails.logger.error "Job Arguments: #{job.arguments}"
    Rails.logger.error e.backtrace.first(10).join("\n")
    raise
  end
end
