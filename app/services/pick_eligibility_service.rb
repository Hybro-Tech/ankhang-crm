# frozen_string_literal: true

# TASK-022b: Pick Eligibility Service
# TASK-060: Updated to use UserServiceTypeLimit and ENV for cooldown
# Checks if a user is eligible to pick a contact based on rules
class PickEligibilityService
  Result = Struct.new(:eligible, :reason, keyword_init: true)

  # Default cooldown in minutes (from ENV or fallback)
  DEFAULT_COOLDOWN_MINUTES = 5

  # Check if user can pick the given contact
  # @param user [User] The user attempting to pick
  # @param contact [Contact] The contact to be picked
  # @return [Result] { eligible: true/false, reason: "..." }
  def self.check(user, contact)
    new(user, contact).check
  end

  def initialize(user, contact)
    @user = user
    @contact = contact
    @service_type = contact.service_type
  end

  def check
    # Check 1: Contact must be pickable
    return Result.new(eligible: false, reason: I18n.t("pick_eligibility.already_picked")) unless @contact.pickable?

    # Check 2: Daily limit per service type (from UserServiceTypeLimit)
    limit_result = check_daily_limit
    return limit_result unless limit_result.eligible

    # Check 3: Cooldown between picks (from ENV)
    cooldown_result = check_cooldown
    return cooldown_result unless cooldown_result.eligible

    # All checks passed
    Result.new(eligible: true, reason: nil)
  end

  private

  # TASK-060: Use UserServiceTypeLimit instead of ServiceType.max_pick_per_day
  def check_daily_limit
    user_limit = UserServiceTypeLimit.find_by(
      user_id: @user.id,
      service_type_id: @service_type&.id
    )

    # If no limit configured for this user + service type, allow unlimited
    return Result.new(eligible: true, reason: nil) unless user_limit

    max_per_day = user_limit.max_pick_per_day

    picked_today = Contact.where(
      assigned_user_id: @user.id,
      service_type_id: @service_type&.id
    ).where(assigned_at: Time.current.beginning_of_day..).count

    if picked_today >= max_per_day
      Result.new(
        eligible: false,
        reason: I18n.t("pick_eligibility.daily_limit_reached", max: max_per_day, type: @service_type&.name)
      )
    else
      remaining = max_per_day - picked_today
      Result.new(eligible: true, reason: I18n.t("pick_eligibility.remaining_picks", remaining: remaining))
    end
  end

  # TASK-060: Use ENV for cooldown (fixed 5 minutes)
  def check_cooldown
    cooldown_minutes = ENV.fetch("PICK_COOLDOWN_MINUTES", DEFAULT_COOLDOWN_MINUTES).to_i

    last_pick = Contact.where(assigned_user_id: @user.id)
                       .where.not(assigned_at: nil)
                       .order(assigned_at: :desc)
                       .limit(1)
                       .pick(:assigned_at)

    return Result.new(eligible: true, reason: nil) if last_pick.blank?

    minutes_since_last_pick = ((Time.current - last_pick) / 60).to_i

    if minutes_since_last_pick < cooldown_minutes
      wait_time = cooldown_minutes - minutes_since_last_pick
      Result.new(
        eligible: false,
        reason: I18n.t("pick_eligibility.cooldown_active", minutes: wait_time)
      )
    else
      Result.new(eligible: true, reason: nil)
    end
  end
end
