namespace :solid_queue do
  desc "Monitor and clean up stuck SolidQueue jobs"
  task monitor: :environment do
    puts "=== SolidQueue Health Check ==="
    
    # Check for old pending jobs
    old_pending = SolidQueue::Job.where(finished_at: nil)
                                 .where("created_at < ?", 1.hour.ago)
    
    if old_pending.exists?
      puts "⚠️  Found #{old_pending.count} jobs older than 1 hour:"
      old_pending.group(:class_name).count.each do |class_name, count|
        puts "  - #{class_name}: #{count} jobs"
      end
    end
    
    # Check for stuck semaphores
    stuck_semaphores = SolidQueue::Semaphore.where("expires_at < ?", Time.current)
    if stuck_semaphores.exists?
      puts "⚠️  Found #{stuck_semaphores.count} expired semaphores:"
      stuck_semaphores.each do |sem|
        puts "  - #{sem.key}: expired #{time_ago_in_words(sem.expires_at)} ago"
      end
    end
    
    # Check for failed executions
    failed_count = SolidQueue::FailedExecution.count
    if failed_count > 0
      puts "⚠️  Found #{failed_count} failed executions"
    end
    
    # Check for blocked executions
    blocked_count = SolidQueue::BlockedExecution.count
    if blocked_count > 0
      puts "⚠️  Found #{blocked_count} blocked executions"
    end
    
    puts "✅ SolidQueue health check complete"
  end
  
  desc "Clean up stuck SolidQueue jobs and semaphores"
  task cleanup: :environment do
    puts "=== SolidQueue Cleanup ==="
    
    # Clean up expired semaphores
    expired_semaphores = SolidQueue::Semaphore.where("expires_at < ?", Time.current)
    if expired_semaphores.exists?
      count = expired_semaphores.delete_all
      puts "🧹 Deleted #{count} expired semaphores"
    end
    
    # Clean up very old failed executions (older than 24 hours)
    old_failed = SolidQueue::FailedExecution.where("created_at < ?", 24.hours.ago)
    if old_failed.exists?
      count = old_failed.delete_all
      puts "🧹 Deleted #{count} old failed executions"
    end
    
    puts "✅ SolidQueue cleanup complete"
  end
end