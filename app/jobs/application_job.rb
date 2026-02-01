# frozen_string_literal: true

# TASK-LOGGING: Base job with user context support
# Jobs can pass user_id to maintain Current.user for activity logging
class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  # Set Current.user and job context before job execution
  # Jobs should pass user_id as last argument if they modify data that needs logging
  around_perform do |job, block|
    job_name = job.class.name
    Current.set(job_context: job_name) do
      block.call
    end
  end

  # Helper method to set Current.user within job
  # Call at beginning of perform if job has user_id
  def with_user_context(user_id)
    return if user_id.blank?

    Current.user = User.find_by(id: user_id)
  end
end
