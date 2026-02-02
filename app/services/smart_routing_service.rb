# frozen_string_literal: true

# TASK-053: Smart Routing Service
# Handles progressive visibility for new contacts during working hours
# rubocop:disable Metrics/ClassLength
class SmartRoutingService
  include NotificationBadgeHelper

  # Initialize visibility when contact is created
  # @param contact [Contact] The newly created contact
  # @return [Boolean] true if routing was applied
  def self.initialize_visibility(contact)
    new(contact).apply_initial_visibility
  end

  # Expand visibility for contacts that have been waiting
  # Called by background job
  # Now reads visibility_expand_minutes from each contact's service_type
  def self.expand_all_pending
    Contact.status_new_contact
           .where(assigned_user_id: nil)
           .where.not(visible_to_user_ids: nil)
           .includes(:service_type)
           .find_each do |contact|
             interval = (contact.service_type&.visibility_expand_minutes || 2).minutes.ago
             next if contact.last_expanded_at && contact.last_expanded_at > interval

             new(contact).expand_visibility
    end
  end

  # Check if contact is visible to user
  # @param contact [Contact] The contact to check
  # @param user [User] The user to check visibility for
  # @return [Boolean]
  def self.visible_to?(contact, user)
    # Already assigned - only visible to assignee
    return contact.assigned_user_id == user.id if contact.assigned_user_id.present?

    # Pool pick mode (no visibility restriction)
    return true if contact.visible_to_user_ids.blank?

    # Check if user is in the visibility list
    contact.visible_to_user_ids.include?(user.id)
  end

  def initialize(contact)
    @contact = contact
  end

  # Set initial visibility when contact is created
  # rubocop:disable Naming/PredicateMethod
  def apply_initial_visibility
    # Check if service type has smart routing disabled → Pool mode → notify all sales
    unless use_smart_routing?
      notify_all_sales_in_team
      return false
    end

    # Outside working hours → Pool mode → notify all sales
    unless should_apply_routing?
      notify_all_sales_in_team
      return false
    end

    team = @contact.service_type&.team
    return false unless team

    # Get first random sale from team
    first_sale = random_sale_from_team(team)
    return false unless first_sale

    @contact.update!(
      visible_to_user_ids: [first_sale.id],
      last_expanded_at: Time.current
    )

    # TASK-057: Notify the first sale
    notify_user_about_contact(first_sale)

    # TASK-055: Broadcast contact row to first Sale (real-time UI update)
    broadcast_contact_to_user(first_sale)

    # TASK-054: Schedule first visibility expansion job
    schedule_expansion_job

    true
  end
  # rubocop:enable Naming/PredicateMethod

  # Add another random sale to visibility list
  def expand_visibility
    return false if @contact.visible_to_user_ids.blank?

    team = @contact.service_type&.team
    return switch_to_pool_pick unless team

    # Get all sales in team who are not yet visible
    next_sale = random_sale_from_team(team, exclude_ids: @contact.visible_to_user_ids)

    if next_sale
      # Add to visibility list
      new_ids = @contact.visible_to_user_ids + [next_sale.id]
      @contact.update!(
        visible_to_user_ids: new_ids,
        last_expanded_at: Time.current
      )

      # TASK-057: Notify the newly visible user
      notify_user_about_contact(next_sale)

      # TASK-055: Broadcast contact row to newly visible user (real-time UI update)
      broadcast_contact_to_user(next_sale)

      true
    else
      # No more sales in team - convert to pool pick
      switch_to_pool_pick
    end
  end

  # Clear visibility queue (called after pick)
  def self.clear_visibility(contact)
    contact.update!(
      visible_to_user_ids: nil,
      last_expanded_at: nil
    )
  end

  private

  def should_apply_routing?
    # Only apply during working hours
    Setting.within_working_hours? &&
      @contact.status_new_contact? &&
      @contact.assigned_user_id.nil?
  end

  # TASK-054: Schedule the first visibility expansion job
  # Passes current user ID for activity logging context
  def schedule_expansion_job
    interval = @contact.service_type&.visibility_expand_minutes || 2
    user_id = Current.user&.id
    SmartRoutingExpandJob.set(wait: interval.minutes).perform_later(@contact.id, user_id)
    Rails.logger.info "[SmartRouting] Scheduled first expansion for contact #{@contact.id} in #{interval} minutes"
  end

  def switch_to_pool_pick # rubocop:disable Naming/PredicateMethod
    # IMPORTANT: Save already_notified BEFORE clearing visible_to_user_ids
    already_notified_ids = @contact.visible_to_user_ids || []

    @contact.update!(
      visible_to_user_ids: nil,
      last_expanded_at: nil
    )

    # TASK-057: Pool mode - notify all sales in team (skip already notified)
    notify_all_sales_in_team(skip_user_ids: already_notified_ids)

    false
  end

  def random_sale_from_team(team, exclude_ids: [])
    # Get users in team with Sale role
    sale_role = Role.find_by(code: Role::SALE)
    return nil unless sale_role

    team.users
        .joins(:user_roles)
        .where(user_roles: { role_id: sale_role.id })
        .where.not(id: exclude_ids)
        .order("RAND()")
        .first
  end

  # Check if service type has smart routing enabled
  def use_smart_routing?
    @contact.service_type&.use_smart_routing != false
  end

  # TASK-057: Send notification to user when contact becomes visible to them
  def notify_user_about_contact(user)
    notification = NotificationService.notify(
      user: user,
      type: "contact_created",
      notifiable: @contact,
      metadata: {
        source: @contact.source&.name,
        service_type_id: @contact.service_type_id
      }
    )

    # Broadcast badge update immediately after creating notification
    broadcast_badge_to_user(user)

    # Broadcast notification item to dropdown (real-time)
    broadcast_notification_to_user(user, notification)

    # TASK-056: Send Web Push notification (for when browser is closed)
    WebPushService.notify_contact_assigned(user, @contact)
  rescue StandardError => e
    Rails.logger.error("Failed to notify user #{user.id} about contact #{@contact.id}: #{e.message}")
  end

  # TASK-055: Broadcast contact row to user via Turbo Streams (real-time UI update)
  def broadcast_contact_to_user(user)
    Turbo::StreamsChannel.broadcast_prepend_to(
      "user_#{user.id}_contacts",
      target: "new_contacts_table_body",
      partial: "sales_workspace/contact_row_broadcast",
      locals: { contact: @contact }
    )

    # Update KPI count
    broadcast_kpi_to_user(user)

    Rails.logger.info "[SmartRouting] Broadcast contact #{@contact.id} to user #{user.id}"
  rescue StandardError => e
    Rails.logger.error("[SmartRouting] Failed to broadcast contact #{@contact.id} to user #{user.id}: #{e.message}")
  end

  # TASK-035: Broadcast notification badge count to user
  def broadcast_badge_to_user(user)
    unread_count = Notification.where(user_id: user.id).unread.count

    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{user.id}_notifications",
      target: "notification_badge",
      html: notification_badge_html(unread_count)
    )
    Rails.logger.info "[SmartRouting] Broadcast badge (#{unread_count}) to user #{user.id}"
  rescue StandardError => e
    Rails.logger.error("[SmartRouting] Failed to broadcast badge to user #{user.id}: #{e.message}")
  end

  # Broadcast notification item to dropdown
  def broadcast_notification_to_user(user, notification)
    return unless notification

    Turbo::StreamsChannel.broadcast_prepend_to(
      "user_#{user.id}_notifications",
      target: "notification_items",
      partial: "notifications/notification",
      locals: { notification: notification }
    )
  rescue StandardError => e
    Rails.logger.error("[SmartRouting] Failed to broadcast notification to user #{user.id}: #{e.message}")
  end

  # Broadcast KPI count update to user
  def broadcast_kpi_to_user(user)
    # Count new contacts visible to this user
    team_ids = user.teams.pluck(:id)
    new_contacts_count = Contact.where(status: :new_contact, team_id: team_ids)
                                .where(assigned_user_id: nil)
                                .where(
                                  "visible_to_user_ids IS NULL OR JSON_CONTAINS(visible_to_user_ids, ?)",
                                  user.id.to_s
                                )
                                .count

    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{user.id}_contacts",
      target: "kpi_new_contacts",
      partial: "shared/kpi_badge",
      locals: { count: new_contacts_count }
    )
  rescue StandardError => e
    Rails.logger.error("[SmartRouting] Failed to broadcast KPI to user #{user.id}: #{e.message}")
  end

  # TASK-057: Pool mode - make contact visible to ALL sales in team and notify them
  # @param skip_user_ids [Array<Integer>] User IDs that have already been notified
  def notify_all_sales_in_team(skip_user_ids: [])
    team = @contact.service_type&.team
    return unless team

    sale_role = Role.find_by(code: Role::SALE)
    return unless sale_role

    # Get all sales in team
    all_sales = team.users
                    .joins(:user_roles)
                    .where(user_roles: { role_id: sale_role.id })

    all_sale_ids = all_sales.pluck(:id)
    return if all_sale_ids.empty?

    # Combine skip_user_ids with any existing visible_to_user_ids
    already_notified = (skip_user_ids + (@contact.visible_to_user_ids || [])).uniq

    # Set visibility to ALL sales (Pool mode = everyone can pick)
    @contact.update!(visible_to_user_ids: all_sale_ids)

    # Notify only those who haven't been notified yet
    all_sales.where.not(id: already_notified).find_each do |user|
      notify_user_about_contact(user)
      broadcast_contact_to_user(user)
    end
  end
end
# rubocop:enable Metrics/ClassLength
