# frozen_string_literal: true

# Handles push subscription management from browser
# API endpoints for Service Worker subscription lifecycle
# SECURITY-AUDIT: Browser push subscriptions - scoped to current_user
class PushSubscriptionsController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check # Browser push subscriptions - scoped to current_user

  # POST /push_subscriptions
  # Called when browser subscribes to push notifications
  def create
    subscription = current_user.push_subscriptions.find_or_initialize_by(
      endpoint: subscription_params[:endpoint]
    )

    subscription.assign_attributes(
      p256dh: subscription_params[:p256dh],
      auth: subscription_params[:auth],
      user_agent: request.user_agent
    )

    if subscription.save
      Rails.logger.info "[WebPush] User #{current_user.id} subscribed: #{subscription.endpoint.first(50)}..."
      render json: { success: true, message: "Đã bật thông báo" }, status: :created
    else
      render json: { success: false, errors: subscription.errors.full_messages }, status: :unprocessable_content
    end
  end

  # DELETE /push_subscriptions
  # Called when user unsubscribes or subscription expires
  def destroy
    endpoint = params[:endpoint]

    if endpoint.blank?
      render json: { success: false, error: "Missing endpoint" }, status: :bad_request
      return
    end

    subscription = current_user.push_subscriptions.find_by(endpoint: endpoint)

    if subscription&.destroy
      Rails.logger.info "[WebPush] User #{current_user.id} unsubscribed"
      render json: { success: true, message: "Đã tắt thông báo" }
    else
      render json: { success: false, error: "Subscription not found" }, status: :not_found
    end
  end

  # GET /push_subscriptions/vapid_public_key
  # Returns VAPID public key for Service Worker
  def vapid_public_key
    config = Rails.application.config.x.vapid

    if config.present? && config[:public_key].present?
      render json: { vapid_public_key: config[:public_key] }
    else
      render json: { error: "VAPID not configured" }, status: :service_unavailable
    end
  end

  private

  def subscription_params
    params.expect(subscription: %i[endpoint p256dh auth])
  end
end
