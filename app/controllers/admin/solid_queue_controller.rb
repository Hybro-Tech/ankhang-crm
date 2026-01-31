# frozen_string_literal: true

# Custom Solid Queue Monitoring Dashboard
# Provides visibility into background job processing with management actions
module Admin
  # rubocop:disable Metrics/ClassLength
  class SolidQueueController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_super_admin!

    def show
      @stats = build_stats
      @queues = fetch_queues
      @recent_jobs = fetch_recent_jobs
      @failed_jobs = fetch_failed_jobs
      @jobs_by_hour = fetch_jobs_by_hour
    end

    # Detail view: Pending jobs (Ready Executions)
    def pending
      @pending_jobs = SolidQueue::ReadyExecution
                      .includes(:job)
                      .order(created_at: :desc)
                      .limit(100)
      @stats = build_stats
    end

    # Detail view: Scheduled jobs
    def scheduled
      @scheduled_jobs = SolidQueue::ScheduledExecution
                        .includes(:job)
                        .order(scheduled_at: :asc)
                        .limit(100)
      @stats = build_stats
    end

    # Detail view: Failed jobs (Full page)
    def failed
      @failed_jobs = SolidQueue::FailedExecution
                     .includes(:job)
                     .order(created_at: :desc)
                     .limit(100)
      @stats = build_stats
    end

    # Detail view: Completed jobs today
    def completed
      @completed_jobs = SolidQueue::Job
                        .where.not(finished_at: nil)
                        .where(finished_at: Time.current.beginning_of_day..)
                        .order(finished_at: :desc)
                        .limit(100)
      @stats = build_stats
    end

    # Retry a single failed job
    def retry
      failed_execution = SolidQueue::FailedExecution.find(params[:id])
      failed_execution.retry
      redirect_to admin_solid_queue_path, notice: "Đã thử lại job #{failed_execution.job_id}"
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_solid_queue_path, alert: "Không tìm thấy job"
    end

    # Retry all failed jobs
    def retry_all
      count = SolidQueue::FailedExecution.count
      SolidQueue::FailedExecution.find_each(&:retry)
      redirect_to admin_solid_queue_path, notice: "Đã thử lại #{count} jobs"
    end

    # Discard a single failed job
    def discard
      failed_execution = SolidQueue::FailedExecution.find(params[:id])
      job = failed_execution.job
      failed_execution.discard
      redirect_to admin_solid_queue_path, notice: "Đã xóa job #{job.id}"
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_solid_queue_path, alert: "Không tìm thấy job"
    end

    # Discard all failed jobs
    def discard_all
      count = SolidQueue::FailedExecution.count
      SolidQueue::FailedExecution.find_each(&:discard)
      redirect_to admin_solid_queue_path, notice: "Đã xóa #{count} failed jobs"
    end

    # Clear completed jobs older than 24 hours
    def clear_completed
      count = SolidQueue::Job.where.not(finished_at: nil)
                             .where(finished_at: ..24.hours.ago)
                             .delete_all
      redirect_to admin_solid_queue_path, notice: "Đã xóa #{count} jobs hoàn thành"
    end

    private

    def authorize_super_admin!
      authorize! :manage, :solid_queue
    end

    def build_stats
      {
        total_jobs: SolidQueue::Job.count,
        pending: SolidQueue::ReadyExecution.count,
        scheduled: SolidQueue::ScheduledExecution.count,
        failed: SolidQueue::FailedExecution.count,
        recurring: SolidQueue::RecurringTask.count,
        processes: SolidQueue::Process.count,
        completed_today: SolidQueue::Job.where(finished_at: Time.current.beginning_of_day..).count
      }
    end

    def fetch_queues
      SolidQueue::ReadyExecution
        .group(:queue_name)
        .select(:queue_name, "COUNT(*) as job_count")
        .order(job_count: :desc)
    end

    def fetch_recent_jobs
      SolidQueue::Job
        .order(created_at: :desc)
        .limit(10)
    end

    def fetch_failed_jobs
      SolidQueue::FailedExecution
        .includes(:job)
        .order(created_at: :desc)
        .limit(10)
    end

    def fetch_jobs_by_hour
      SolidQueue::Job
        .where(created_at: 24.hours.ago..)
        .group_by_hour(:created_at)
        .count
    end
  end
  # rubocop:enable Metrics/ClassLength
end
