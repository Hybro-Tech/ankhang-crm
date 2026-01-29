# frozen_string_literal: true

# TASK-053: Background job to expand Smart Routing visibility
# Runs periodically (every minute) to check pending contacts and expand visibility
class SmartRoutingExpandJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "[SmartRouting] Expanding visibility for pending contacts..."

    SmartRoutingService.expand_all_pending

    Rails.logger.info "[SmartRouting] Visibility expansion complete"
  end
end
