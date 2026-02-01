# frozen_string_literal: true

# TASK-035: Contact broadcast concern
# Handles Turbo Streams broadcasts for real-time updates
# Extracted from Contact model to follow SRP
module ContactBroadcastable
  extend ActiveSupport::Concern
  include NotificationBadgeHelper

  included do
    # TASK-035/054: Real-time broadcasts (must run AFTER commit for solid_cable to work)
    after_create_commit :initialize_smart_routing_and_broadcast
    after_update_commit :broadcast_contact_picked, if: :saved_change_to_assigned_user_id?
  end

  private

  # TASK-035/054: Initialize Smart Routing and broadcast (runs AFTER commit)
  # Combined method to ensure proper order: visibility → notify → broadcast
  def initialize_smart_routing_and_broadcast
    # Skip in test environment (no Warden context for can? helper in partial)
    return if Rails.env.test?
    # Guard: Only run on actual CREATE
    return unless just_created?

    # Clear flag immediately to prevent duplicate calls
    @just_created = false

    # Initialize Smart Routing (sets visibility + sends notifications + broadcasts contact + badge)
    SmartRoutingService.initialize_visibility(self)

    Rails.logger.info "[Contact#after_create_commit] Contact #{id} - smart routing initialized"
  rescue StandardError => e
    Rails.logger.error "[Contact#after_create_commit] Error: #{e.message}"
  end

  # TASK-035: Broadcast contact picked - remove from other users' lists
  def broadcast_contact_picked
    return if Rails.env.test?
    return if assigned_user_id.blank?

    # Broadcast to global stream to remove this contact from all lists
    Turbo::StreamsChannel.broadcast_remove_to(
      "contacts_global",
      target: dom_id(self)
    )

    # Also broadcast to specific users who could see this contact before
    previous_visible_ids = visible_to_user_ids_before_last_save || []
    previous_visible_ids.each do |user_id|
      next if user_id == assigned_user_id # Don't remove from picker's list

      Turbo::StreamsChannel.broadcast_remove_to(
        "user_#{user_id}_contacts",
        target: dom_id(self)
      )
    end

    Rails.logger.info "[Contact#broadcast_picked] Contact #{id} picked by user #{assigned_user_id}"
  rescue StandardError => e
    Rails.logger.error "[Contact#broadcast_picked] Error: #{e.message}"
  end

  # Helper: Calculate which users can see this contact
  def calculate_visible_user_ids
    if visible_to_user_ids.present?
      # Smart Routing mode: specific users
      visible_to_user_ids
    else
      # Pool mode: all active sales users in the same team
      team_users = fetch_team_user_ids
      # Also include super admins (they can see all)
      admin_ids = User.joins(:roles).where(roles: { code: Role::SUPER_ADMIN }).active.distinct.pluck(:id)
      (team_users + admin_ids).uniq
    end
  end

  def fetch_team_user_ids
    return [] unless team

    team.users.active.pluck(:id)
  end

  # Broadcast to update notification badge count for users
  def broadcast_notification_badge_update
    visible_user_ids = calculate_visible_user_ids
    return if visible_user_ids.empty?

    visible_user_ids.each do |user_id|
      unread_count = Notification.where(user_id: user_id).unread.count

      Turbo::StreamsChannel.broadcast_replace_to(
        "user_#{user_id}_notifications",
        target: "notification_badge",
        html: notification_badge_html(unread_count)
      )
    end

    Rails.logger.info "[Contact#broadcast_badge] Badge updated for #{visible_user_ids.size} users"
  end

  # TASK-035: Broadcast new contact row to Sales Dashboard
  def broadcast_contact_list_update
    visible_user_ids = calculate_visible_user_ids
    return if visible_user_ids.empty?

    visible_user_ids.each do |user_id|
      # Broadcast to Sales Dashboard (new_contacts_table_body)
      Turbo::StreamsChannel.broadcast_prepend_to(
        "user_#{user_id}_contacts",
        target: "new_contacts_table_body",
        partial: "sales_workspace/contact_row_broadcast",
        locals: { contact: self }
      )
    end

    Rails.logger.info "[Contact#broadcast_list] Contact #{id} added to #{visible_user_ids.size} users' dashboards"
  end
end
