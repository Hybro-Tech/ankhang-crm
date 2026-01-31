# frozen_string_literal: true

# == Schema Information
#
# Table name: push_subscriptions
#
#  id         :bigint           not null, primary key
#  auth       :string(255)      not null
#  endpoint   :string(255)      not null
#  p256dh     :string(255)      not null
#  user_agent :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_push_subscriptions_on_user_id              (user_id)
#  index_push_subscriptions_on_user_id_and_endpoint (user_id,endpoint) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, presence: true, uniqueness: { scope: :user_id }
  validates :p256dh, presence: true
  validates :auth, presence: true

  # Send a push notification to this subscription
  # @param title [String] Notification title
  # @param body [String] Notification body
  # @param options [Hash] Additional options (url, icon, etc.)
  def send_notification(title:, body:, **options)
    WebPush.payload_send(
      message: build_payload(title, body, options).to_json,
      endpoint: endpoint,
      p256dh: p256dh,
      auth: auth,
      vapid: Rails.application.config.x.vapid
    )

    Rails.logger.info "[WebPush] Sent notification to user #{user_id}: #{title}"
    true
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription => e
    handle_invalid_subscription(e)
  rescue StandardError => e
    Rails.logger.error "[WebPush] Failed to send notification to user #{user_id}: #{e.message}"
    false
  end

  private

  def build_payload(title, body, options)
    {
      title: title,
      body: body,
      icon: options[:icon] || "/icon.png",
      badge: options[:badge] || "/icon.png",
      url: options[:url] || "/",
      tag: options[:tag],
      data: options[:data] || {}
    }.compact
  end

  def handle_invalid_subscription(exception)
    Rails.logger.warn "[WebPush] Subscription expired/invalid for user #{user_id}, removing: #{exception.message}"
    destroy
    false
  end
end
