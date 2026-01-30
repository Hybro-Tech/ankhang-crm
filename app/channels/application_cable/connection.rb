# frozen_string_literal: true

# TASK-035: ActionCable Connection with Devise Authentication
# Identifies WebSocket connections by current_user for user-specific streams
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    # Use Devise's warden to find the current user from session
    def find_verified_user
      verified_user = env["warden"].user

      verified_user || reject_unauthorized_connection
    end
  end
end
