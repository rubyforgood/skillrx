FactoryBot.define do
  factory :solid_queue_job, class: "SolidQueue::Job" do
    queue_name { "default" }
    class_name { "TestJob" }
    arguments { [ 1, "test" ] }
    priority { 0 }
    active_job_id { SecureRandom.uuid }
    scheduled_at { Time.current }
    finished_at { nil }
    concurrency_key { nil }
  end

  factory :solid_queue_semaphore, class: "SolidQueue::Semaphore" do
    key { "test_key" }
    value { 1 }
    expires_at { 1.hour.from_now }
  end

  factory :solid_queue_failed_execution, class: "SolidQueue::FailedExecution" do
    association :job, factory: :solid_queue_job
    error { { "exception_class" => "StandardError", "message" => "Test error" } }
    created_at { Time.current }
  end

  factory :solid_queue_blocked_execution, class: "SolidQueue::BlockedExecution" do
    association :job, factory: :solid_queue_job
    concurrency_key { "test_key" }
    expires_at { 3.minutes.from_now }
    created_at { Time.current }
  end
end
