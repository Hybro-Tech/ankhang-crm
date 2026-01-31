# frozen_string_literal: true

# Custom Solid Cache Monitoring Dashboard
# Provides visibility into cache performance and entries with management actions
module Admin
  class SolidCacheController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_super_admin!

    def show
      @stats = build_stats
      @recent_entries = fetch_recent_entries
      @entries_by_hour = fetch_entries_by_hour
    end

    # Clear all cache entries
    def clear_all
      count = SolidCache::Entry.count
      SolidCache::Entry.delete_all
      redirect_to admin_solid_cache_path, notice: "Đã xóa #{count} cache entries"
    end

    # Clear old cache entries (older than 24 hours)
    def clear_old
      count = SolidCache::Entry.where(created_at: ..24.hours.ago).delete_all
      redirect_to admin_solid_cache_path, notice: "Đã xóa #{count} cache entries cũ"
    end

    # Delete a specific cache entry
    def destroy
      entry = SolidCache::Entry.find_by(key_hash: params[:id])
      if entry
        entry.delete
        redirect_to admin_solid_cache_path, notice: "Đã xóa cache entry"
      else
        redirect_to admin_solid_cache_path, alert: "Không tìm thấy cache entry"
      end
    end

    private

    def authorize_super_admin!
      authorize! :manage, :solid_cache
    end

    def cache_entries
      @cache_entries ||= SolidCache::Entry.all
    end

    def build_stats
      {
        total_entries: cache_entries.count,
        total_size: calculate_total_size,
        oldest_entry: cache_entries.minimum(:created_at),
        newest_entry: cache_entries.maximum(:created_at),
        entries_last_hour: cache_entries.where(created_at: 1.hour.ago..).count,
        entries_last_24h: cache_entries.where(created_at: 24.hours.ago..).count
      }
    end

    def calculate_total_size
      # Estimate size based on value column
      total_bytes = cache_entries.sum("LENGTH(value)")
      format_bytes(total_bytes)
    end

    def format_bytes(bytes)
      return "0 B" if bytes.nil? || bytes.zero?

      units = %w[B KB MB GB]
      exp = (Math.log(bytes) / Math.log(1024)).to_i
      exp = [exp, units.length - 1].min
      "#{(bytes.to_f / (1024**exp)).round(2)} #{units[exp]}"
    end

    def fetch_recent_entries
      cache_entries
        .order(created_at: :desc)
        .limit(20)
        .select(:key_hash, :created_at, "LENGTH(value) as size_bytes")
    end

    def fetch_entries_by_hour
      cache_entries
        .where(created_at: 24.hours.ago..)
        .group_by_hour(:created_at)
        .count
    end
  end
end
