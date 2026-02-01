# frozen_string_literal: true

# TASK-LOGGING: Tier 2 - Request Tracker Middleware
# Insert after Warden (Devise) so we have access to current_user

require_relative "../../app/middleware/request_tracker"

Rails.application.config.middleware.insert_after Warden::Manager, RequestTracker::Middleware
