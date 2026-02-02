# frozen_string_literal: true

# TASK-022b: Pick Eligibility Service
# Checks if a user is eligible to pick a contact based on rules
class PickEligibilityService
  Result = Struct.new(:eligible, :reason, keyword_init: true)

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

    # Check 2: Daily limit per service type
    limit_result = check_daily_limit
    return limit_result unless limit_result.eligible

    # Check 3: Cooldown between picks
    cooldown_result = check_cooldown
    return cooldown_result unless cooldown_result.eligible

    # All checks passed
    Result.new(eligible: true, reason: nil)
  end

  private

  # Check if user has reached daily pick limit for this service type
  def check_daily_limit
    max_per_day = @service_type&.max_pick_per_day || 20

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

  # Check if user is still in cooldown period
  def check_cooldown
    cooldown_minutes = @service_type&.pick_cooldown_minutes || 5

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
