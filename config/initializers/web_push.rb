# frozen_string_literal: true

# Web Push configuration using VAPID keys
# Required for sending push notifications to browsers

# Skip initialization if keys are not configured
if ENV["VAPID_PUBLIC_KEY"].present? && ENV["VAPID_PRIVATE_KEY"].present?
  Rails.application.config.x.vapid = {
    public_key: ENV.fetch("VAPID_PUBLIC_KEY"),
    private_key: ENV.fetch("VAPID_PRIVATE_KEY"),
    subject: ENV.fetch("VAPID_SUBJECT", "mailto:admin@ankhang.com")
  }

  Rails.logger.info "[WebPush] VAPID keys configured successfully"
else
  Rails.logger.warn "[WebPush] VAPID keys not configured. Web Push notifications will be disabled."
end
