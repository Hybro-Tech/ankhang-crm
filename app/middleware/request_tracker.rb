# frozen_string_literal: true

# TASK-LOGGING: Tier 2 - Request Tracker Middleware
# Logs all user requests to user_events table
#
# Excludes:
#   - Static assets (/assets, /packs, /vite)
#   - Health checks (/up, /health)
#   - Turbo/Cable streams
#   - Anonymous requests (no user session) - optional
#
module RequestTracker
  class Middleware
    # Paths to exclude from logging
    EXCLUDED_PATHS = [
      %r{^/assets},
      %r{^/packs},
      %r{^/vite},
      %r{^/up$},
      %r{^/health},
      %r{^/cable},
      %r{^/rails/action_mailbox},
      %r{^/rails/active_storage},
      /\.ico$/,
      /\.png$/,
      /\.jpg$/,
      /\.svg$/,
      /\.js$/,
      /\.css$/,
      /\.map$/,
      /\.woff/,
      /\.ttf$/
    ].freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      # Call the app
      status, headers, response = @app.call(env)

      # Log after response (non-blocking)
      log_request(env, status, start_time) unless skip_logging?(env)

      [status, headers, response]
    rescue StandardError => e
      # Don't fail the request if logging fails
      Rails.logger.error("[RequestTracker] Error: #{e.message}")
      raise
    end

    private

    def skip_logging?(env)
      path = env["PATH_INFO"]

      # Skip excluded paths
      return true if EXCLUDED_PATHS.any? { |pattern| path.match?(pattern) }

      # Skip if no user session (optional - remove if you want to log anonymous)
      # warden = env['warden']
      # return true if warden.nil? || !warden.authenticated?

      false
    end

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def log_request(env, status, start_time)
      duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).round

      # Get Warden/Devise user
      warden = env["warden"]
      user = warden&.user

      # Get request details
      request = Rack::Request.new(env)

      UserEvent.create!(
        user_id: user&.id,
        event_type: determine_event_type(request),
        path: request.path.truncate(500),
        method: request.request_method,
        controller: env["action_controller.instance"]&.class&.name,
        action: env["action_controller.instance"]&.action_name,
        params: sanitize_params(request),
        response_status: status,
        duration_ms: duration_ms,
        ip_address: request.ip,
        user_agent: request.user_agent,
        session_id: request.session.id.to_s.truncate(100),
        request_id: env["action_dispatch.request_id"]
      )
    rescue StandardError => e
      # Don't fail the request if logging fails
      Rails.logger.error("[RequestTracker] Failed to log: #{e.message}")
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    def determine_event_type(request)
      case request.request_method
      when "GET"
        request.xhr? ? "ajax" : "page_view"
      when "POST", "PUT", "PATCH", "DELETE"
        request.xhr? ? "ajax" : "form_submit"
      else
        "api_call"
      end
    end

    def sanitize_params(request)
      params = request.params.except("controller", "action", "authenticity_token")

      # Remove sensitive data
      sensitive_keys = %w[password password_confirmation token secret key credential]
      sanitize_hash(params, sensitive_keys)
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def sanitize_hash(hash, sensitive_keys)
      hash.transform_values do |value|
        case value
        when Hash
          sanitize_hash(value, sensitive_keys)
        when String
          hash.keys.any? { |k| sensitive_keys.any? { |s| k.to_s.include?(s) } } ? "[FILTERED]" : value
        else
          value
        end
      end
    rescue StandardError
      {} # Return empty hash if sanitization fails
    end
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
