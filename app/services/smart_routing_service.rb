# frozen_string_literal: true

# TASK-066: Smart Routing Service - 3-Layer Distribution System
# Layer 1: Fair Random within Team (T+0)
# Layer 2: Regional Pool (T+REGIONAL_EXPAND_MINUTES)
# Layer 3: National Pool (T+VISIBILITY_EXPAND_MINUTES)
# rubocop:disable Metrics/ClassLength
class SmartRoutingService
  include NotificationBadgeHelper

  # ENV defaults
  DEFAULT_REGIONAL_EXPAND_MINUTES = 2
  DEFAULT_VISIBILITY_EXPAND_MINUTES = 4

  # Initialize visibility when contact is created
  # @param contact [Contact] The newly created contact
  # @return [Boolean] true if routing was applied
  def self.initialize_visibility(contact)
    new(contact).apply_initial_visibility
  end

  # Expand visibility for contacts - called by background job
  def self.expand_visibility_for(contact)
    new(contact).expand_visibility
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

  # Clear visibility queue (called after pick)
  def self.clear_visibility(contact)
    contact.update!(
      visible_to_user_ids: nil,
      last_expanded_at: nil
    )
  end

  def initialize(contact)
    @contact = contact
  end

  # Layer 1: Set initial visibility to random Sale in Team
  # rubocop:disable Metrics/MethodLength, Naming/PredicateMethod
  def apply_initial_visibility
    # Outside working hours → Skip to National Pool (Layer 3)
    unless should_apply_routing?
      switch_to_national_pool
      return false
    end

    team = @contact.service_type&.team
    unless team
      # No team configured → Skip to Regional Pool (Layer 2)
      switch_to_regional_pool
      return false
    end

    # Get first random sale from team
    first_sale = random_sale_from_team(team)
    unless first_sale
      # No sales in team → Skip to Regional Pool
      switch_to_regional_pool
      return false
    end

    @contact.update!(
      visible_to_user_ids: [first_sale.id],
      last_expanded_at: Time.current,
      routing_layer: 1
    )

    # Notify the first sale
    notify_user_about_contact(first_sale)
    broadcast_contact_to_user(first_sale)

    # Schedule Layer 2 expansion
    schedule_layer2_expansion

    Rails.logger.info "[SmartRouting] Layer 1: Contact #{@contact.id} → User #{first_sale.id} (Team: #{team.name})"
    true
  end
  # rubocop:enable Metrics/MethodLength, Naming/PredicateMethod

  # Expand visibility based on current layer
  def expand_visibility
    return false if @contact.assigned_user_id.present?
    return false unless @contact.status_new_contact?

    current_layer = @contact.routing_layer || 1

    case current_layer
    when 1
      expand_to_layer2
    when 2
      expand_to_layer3
    else
      false
    end
  end

  private

  # ============================================================================
  # Layer Expansion Methods
  # ============================================================================

  # Layer 2: Expand to Regional Pool
  def expand_to_layer2
    already_notified_ids = @contact.visible_to_user_ids || []

    regional_sales = find_regional_sales
    if regional_sales.empty?
      # No regional sales → Skip to Layer 3
      return expand_to_layer3
    end

    all_visible_ids = (already_notified_ids + regional_sales.pluck(:id)).uniq

    @contact.update!(
      visible_to_user_ids: all_visible_ids,
      last_expanded_at: Time.current,
      routing_layer: 2
    )

    # Notify new users only
    new_user_ids = all_visible_ids - already_notified_ids
    regional_sales.where(id: new_user_ids).find_each do |user|
      notify_user_about_contact(user)
      broadcast_contact_to_user(user)
    end

    # Schedule Layer 3 expansion
    schedule_layer3_expansion

    Rails.logger.info "[SmartRouting] Layer 2: Contact #{@contact.id} → Regional Pool (#{new_user_ids.size} new users)"
    true
  end

  # Layer 3: Expand to National Pool (all sales can pick)
  def expand_to_layer3 # rubocop:disable Naming/PredicateMethod
    switch_to_national_pool
    true
  end

  # ============================================================================
  # Pool Switch Methods
  # ============================================================================

  def switch_to_regional_pool
    regional_sales = find_regional_sales

    if regional_sales.empty?
      # No regional sales → Go directly to National
      switch_to_national_pool
      return
    end

    regional_ids = regional_sales.pluck(:id)

    @contact.update!(
      visible_to_user_ids: regional_ids,
      last_expanded_at: Time.current,
      routing_layer: 2
    )

    regional_sales.find_each do |user|
      notify_user_about_contact(user)
      broadcast_contact_to_user(user)
    end

    schedule_layer3_expansion
    regional_count = regional_ids.size
    Rails.logger.info "[SmartRouting] Direct Layer 2: Contact #{@contact.id} → Regional Pool (#{regional_count} users)"
  end

  def switch_to_national_pool
    already_notified_ids = @contact.visible_to_user_ids || []

    @contact.update!(
      visible_to_user_ids: nil,
      last_expanded_at: nil,
      routing_layer: 3
    )

    # Notify all sales NOT already notified
    notify_all_sales(skip_user_ids: already_notified_ids)

    Rails.logger.info "[SmartRouting] Layer 3: Contact #{@contact.id} → National Pool"
  end

  # ============================================================================
  # Helper Methods
  # ============================================================================

  def should_apply_routing?
    Setting.within_working_hours? &&
      @contact.status_new_contact? &&
      @contact.assigned_user_id.nil?
  end

  def random_sale_from_team(team)
    sale_role = Role.find_by(code: Role::SALE)
    return nil unless sale_role

    team.users
        .joins(:user_roles)
        .where(user_roles: { role_id: sale_role.id })
        .where(status: :active)
        .order("RAND()")
        .first
  end

  # Find all sales users in the same region as the contact's province
  def find_regional_sales
    contact_province = @contact.province
    return User.none unless contact_province

    # Get regions that this province belongs to
    region_ids = contact_province.regions.pluck(:id)
    return User.none if region_ids.empty?

    sale_role = Role.find_by(code: Role::SALE)
    return User.none unless sale_role

    # Find all active sales users in these regions
    User.joins(:user_roles)
        .where(user_roles: { role_id: sale_role.id })
        .where(region_id: region_ids)
        .where(status: :active)
  end

  # ============================================================================
  # Job Scheduling
  # ============================================================================

  def schedule_layer2_expansion
    interval = ENV.fetch("REGIONAL_EXPAND_MINUTES", DEFAULT_REGIONAL_EXPAND_MINUTES).to_i
    user_id = Current.user&.id
    SmartRoutingExpandJob.set(wait: interval.minutes).perform_later(@contact.id, user_id)
    Rails.logger.info "[SmartRouting] Scheduled Layer 2 for contact #{@contact.id} in #{interval} minutes"
  end

  def schedule_layer3_expansion
    interval = ENV.fetch("VISIBILITY_EXPAND_MINUTES", DEFAULT_VISIBILITY_EXPAND_MINUTES).to_i
    user_id = Current.user&.id
    SmartRoutingExpandJob.set(wait: interval.minutes).perform_later(@contact.id, user_id)
    Rails.logger.info "[SmartRouting] Scheduled Layer 3 for contact #{@contact.id} in #{interval} minutes"
  end

  # ============================================================================
  # Notification Methods
  # ============================================================================

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

    broadcast_badge_to_user(user)
    broadcast_notification_to_user(user, notification)
    WebPushService.notify_contact_assigned(user, @contact)
  rescue StandardError => e
    Rails.logger.error("Failed to notify user #{user.id} about contact #{@contact.id}: #{e.message}")
  end

  def broadcast_contact_to_user(user)
    Turbo::StreamsChannel.broadcast_prepend_to(
      "user_#{user.id}_contacts",
      target: "new_contacts_table_body",
      partial: "sales_workspace/contact_row_broadcast",
      locals: { contact: @contact }
    )

    broadcast_kpi_to_user(user)
  rescue StandardError => e
    Rails.logger.error("[SmartRouting] Failed to broadcast contact #{@contact.id} to user #{user.id}: #{e.message}")
  end

  def broadcast_badge_to_user(user)
    unread_count = Notification.where(user_id: user.id).unread.count

    Turbo::StreamsChannel.broadcast_replace_to(
      "user_#{user.id}_notifications",
      target: "notification_badge",
      html: notification_badge_html(unread_count)
    )
  rescue StandardError => e
    Rails.logger.error("[SmartRouting] Failed to broadcast badge to user #{user.id}: #{e.message}")
  end

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

  def broadcast_kpi_to_user(user)
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

  # Notify all active sales users (for National Pool)
  def notify_all_sales(skip_user_ids: [])
    sale_role = Role.find_by(code: Role::SALE)
    return unless sale_role

    all_sales = User.joins(:user_roles)
                    .where(user_roles: { role_id: sale_role.id })
                    .where(status: :active)
                    .where.not(id: skip_user_ids)

    all_sales.find_each do |user|
      notify_user_about_contact(user)
      broadcast_contact_to_user(user)
    end
  end
end
# rubocop:enable Metrics/ClassLength
