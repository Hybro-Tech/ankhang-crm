# frozen_string_literal: true

# Hidden System Monitoring Portal
# Only accessible to super_admin via direct URL /solid
module Admin
  class SolidController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_super_admin!

    def index
      @queue_stats = build_queue_stats
      @cache_stats = build_cache_stats
      @cable_stats = build_cable_stats
    end

    private

    def authorize_super_admin!
      authorize! :manage, :solid_queue
    end

    def build_queue_stats
      {
        total_jobs: SolidQueue::Job.count,
        pending: SolidQueue::ReadyExecution.count,
        failed: SolidQueue::FailedExecution.count,
        processes: SolidQueue::Process.count
      }
    end

    def build_cache_stats
      {
        total_entries: SolidCache::Entry.count,
        total_size: format_bytes(SolidCache::Entry.sum("LENGTH(value)"))
      }
    end

    def build_cable_stats
      {
        total_messages: SolidCable::Message.count,
        channels: SolidCable::Message.distinct.count(:channel_hash)
      }
    end

    def format_bytes(bytes)
      return "0 B" if bytes.nil? || bytes.zero?

      units = %w[B KB MB GB]
      exp = (Math.log(bytes) / Math.log(1024)).to_i
      exp = [exp, units.length - 1].min
      "#{(bytes.to_f / (1024**exp)).round(2)} #{units[exp]}"
    end
  end
end
