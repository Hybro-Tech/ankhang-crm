# frozen_string_literal: true

# TASK-043: Rack::Attack Configuration for Rate Limiting & Throttling
# Protects against brute-force attacks, password guessing, and DDoS

module Rack
  class Attack
    # ==== Cache Store ====
    # Use Rails cache (Solid Cache in production)
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    # ==== Safelist ====
    # Always allow requests from localhost in development
    safelist("allow-localhost") do |req|
      ["127.0.0.1", "::1"].include?(req.ip)
    end

    # ==== Throttle: Login Attempts ====
    # Limit login attempts to prevent password brute-forcing
    # Key: "throttle:logins/ip:#{req.ip}"
    throttle("logins/ip", limit: 5, period: 60.seconds) do |req|
      req.ip if req.path == "/users/sign_in" && req.post?
    end

    # Limit login attempts per email to prevent targeted password guessing
    throttle("logins/email", limit: 5, period: 60.seconds) do |req|
      if req.path == "/users/sign_in" && req.post?
        # Normalize email to lowercase
        req.params.dig("user", "email").to_s.downcase.gsub(/\s+/, "").presence
      end
    end

    # ==== Throttle: Password Reset ====
    # Limit password reset requests to prevent email bombing
    throttle("password_resets/ip", limit: 3, period: 300.seconds) do |req|
      req.ip if req.path == "/users/password" && req.post?
    end

    throttle("password_resets/email", limit: 3, period: 300.seconds) do |req|
      if req.path == "/users/password" && req.post?
        req.params.dig("user", "email").to_s.downcase.gsub(/\s+/, "").presence
      end
    end

    # ==== Throttle: API Requests ====
    # General rate limit for API requests
    throttle("api/ip", limit: 100, period: 60.seconds) do |req|
      req.ip if req.path.start_with?("/api/")
    end

    # ==== Throttle: General Requests ====
    # Prevent DDoS by limiting overall requests per IP
    throttle("requests/ip", limit: 300, period: 5.minutes) do |req|
      req.ip unless req.path.start_with?("/assets", "/packs")
    end

    # ==== Response for Throttled Requests ====
    # Return 429 Too Many Requests with retry info
    self.throttled_responder = lambda do |request|
      match_data = request.env["rack.attack.match_data"]
      now = Time.now.utc

      retry_after = (match_data[:period] - (now.to_i % match_data[:period])).to_s

      [
        429,
        {
          "Content-Type" => "application/json",
          "Retry-After" => retry_after
        },
        [{ error: "Too many requests. Please retry later.", retry_after: retry_after }.to_json]
      ]
    end

    # ==== Logging ====
    # Log throttled and blocked requests for monitoring
    ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _request_id, payload|
      req = payload[:request]
      Rails.logger.warn "[Rack::Attack] Throttled #{req.ip} for #{req.path}"
    end

    ActiveSupport::Notifications.subscribe("blocklist.rack_attack") do |_name, _start, _finish, _request_id, payload|
      req = payload[:request]
      Rails.logger.warn "[Rack::Attack] Blocked #{req.ip} for #{req.path}"
    end
  end
end
