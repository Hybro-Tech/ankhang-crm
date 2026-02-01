# frozen_string_literal: true

# TASK-LOGGING: Current attributes for thread-safe request context
# Used by Loggable concern to access current user and request info in models
#
# Set in ApplicationController:
#   Current.user = current_user
#   Current.ip_address = request.remote_ip
#   Current.user_agent = request.user_agent
#
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :ip_address, :user_agent, :request_id
end
