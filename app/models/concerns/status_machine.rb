# frozen_string_literal: true

# TASK-051: Contact Status State Machine
# TASK-064: Simplified to 4 states only
# Defines valid transitions and transition logic
module StatusMachine
  extend ActiveSupport::Concern

  # ============================================================================
  # Valid Transitions (SRS v4 - Simplified)
  # ============================================================================
  # Key = current status, Value = array of valid next statuses
  VALID_TRANSITIONS = {
    new_contact: [:potential],          # Mới → Tiềm năng (Sale nhận)
    potential: %i[closed failed],       # Tiềm năng → Chốt/Thất bại
    failed: [:potential],               # Thất bại → Tiềm năng (CSKH recovery)
    closed: [] # Chốt - End state
  }.freeze

  # Status labels for UI
  STATUS_LABELS = {
    new_contact: "Mới",
    potential: "Tiềm năng",
    failed: "Thất bại",
    closed: "Chốt"
  }.freeze

  # Status colors for UI badges
  STATUS_COLORS = {
    new_contact: "bg-blue-100 text-blue-700",
    potential: "bg-teal-100 text-teal-700",
    failed: "bg-red-100 text-red-700",
    closed: "bg-green-100 text-green-700"
  }.freeze

  included do
    # Track status changes for logging
    attr_accessor :status_changed_by, :status_change_reason
  end

  # ============================================================================
  # Instance Methods
  # ============================================================================

  # Check if transition to new_status is valid
  def can_transition_to?(new_status)
    new_status = new_status.to_sym
    current = status.to_sym

    valid_targets = VALID_TRANSITIONS[current] || []
    valid_targets.include?(new_status)
  end

  # Perform transition with validation and logging
  # rubocop:disable Naming/PredicateMethod
  def transition_to!(new_status, user: nil, reason: nil)
    new_status = new_status.to_sym
    old_status = status.to_sym

    unless can_transition_to?(new_status)
      raise InvalidTransitionError, "Không thể chuyển từ '#{status_label}' sang '#{STATUS_LABELS[new_status]}'"
    end

    # Store for logging
    self.status_changed_by = user
    self.status_change_reason = reason

    # Update status
    self.status = new_status

    # Set timestamps for closed states
    self.closed_at = Time.current if closed_state?(new_status)

    save!

    # Log the transition
    log_status_transition(old_status, new_status, user, reason)

    true
  end
  # rubocop:enable Naming/PredicateMethod

  # Get list of valid next statuses for UI dropdown
  def available_transitions
    current = status.to_sym
    (VALID_TRANSITIONS[current] || []).map do |next_status|
      {
        value: next_status,
        label: STATUS_LABELS[next_status],
        color: STATUS_COLORS[next_status]
      }
    end
  end

  # Check if there are any available transitions
  def can_change_status?
    available_transitions.present?
  end

  # Get label for current status
  def status_label
    STATUS_LABELS[status.to_sym] || status.humanize
  end

  # Get color class for current status
  def status_color
    STATUS_COLORS[status.to_sym] || "bg-gray-100 text-gray-700"
  end

  # Check if current status is a closed/end state
  def closed_state?(check_status = nil)
    check_status ||= status.to_sym
    check_status.to_sym == :closed
  end

  # Check if current status is failed
  def failed_state?
    status.to_sym == :failed
  end

  # TASK-064: Removed cskh_state? since CSKH levels no longer exist

  private

  # Log status transition (creates Interaction record)
  def log_status_transition(from_status, to_status, user, reason)
    return if user.blank?

    content = "Chuyển trạng thái: #{STATUS_LABELS[from_status]} → #{STATUS_LABELS[to_status]}"
    content += "\nLý do: #{reason}" if reason.present?

    interactions.create!(
      user: user,
      content: content,
      interaction_method: :note
    )
  end

  # Custom error class for invalid transitions
  class InvalidTransitionError < StandardError; end
end
