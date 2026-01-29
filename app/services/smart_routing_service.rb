# frozen_string_literal: true

# TASK-053: Smart Routing Service
# Handles progressive visibility for new contacts during working hours
class SmartRoutingService
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
    Contact.where(status: "new")
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
    return false unless should_apply_routing?

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
      @contact.status == "new" &&
      @contact.assigned_user_id.nil?
  end

  # rubocop:disable Naming/PredicateMethod
  def switch_to_pool_pick
    @contact.update!(
      visible_to_user_ids: nil,
      last_expanded_at: nil
    )
    false
  end
  # rubocop:enable Naming/PredicateMethod

  def random_sale_from_team(team, exclude_ids: [])
    # Get users in team with Sale role
    sale_role = Role.find_by(code: "sale")
    return nil unless sale_role

    team.users
        .joins(:user_roles)
        .where(user_roles: { role_id: sale_role.id })
        .where.not(id: exclude_ids)
        .order("RAND()")
        .first
  end

  # TASK-057: Send notification to user when contact becomes visible to them
  def notify_user_about_contact(user)
    NotificationService.notify(
      user: user,
      type: "contact_created",
      notifiable: @contact,
      metadata: {
        source: @contact.source&.name,
        service_type_id: @contact.service_type_id
      }
    )
  rescue StandardError => e
    Rails.logger.error("Failed to notify user #{user.id} about contact #{@contact.id}: #{e.message}")
  end
end
