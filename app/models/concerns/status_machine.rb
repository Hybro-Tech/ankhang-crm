# frozen_string_literal: true

# TASK-051: Contact Status State Machine
# Defines valid transitions and transition logic
module StatusMachine
  extend ActiveSupport::Concern

  # ============================================================================
  # Valid Transitions (SRS v3 Section 5.3)
  # ============================================================================
  # Key = current status, Value = array of valid next statuses
  VALID_TRANSITIONS = {
    new_contact: [:potential], # Mới → Tiềm năng (Sale nhận)
    potential: %i[in_progress potential_old failed],  # Tiềm năng → Đang tư vấn/Tiềm năng cũ/Thất bại
    potential_old: %i[closed_old failed in_progress], # Tiềm năng cũ → Chốt Cũ/Thất bại/Đang tư vấn
    in_progress: %i[closed_new failed], # Đang tư vấn → Chốt Mới/Thất bại
    closed_new: [],                                      # Chốt Mới - End state
    closed_old: [],                                      # Chốt Cũ - End state
    failed: [:cskh_l1],                                  # Thất bại → CSKH L1
    cskh_l1: %i[closed_new cskh_l2], # CSKH L1 → Chốt Mới/CSKH L2
    cskh_l2: [:closed],                                  # CSKH L2 → Đóng
    closed: []                                           # Đóng - End state
  }.freeze

  # Status labels for UI
  STATUS_LABELS = {
    new_contact: "Mới",
    potential: "Tiềm năng",
    in_progress: "Đang tư vấn",
    potential_old: "Tiềm năng cũ",
    closed_new: "Chốt Mới",
    closed_old: "Chốt Cũ",
    failed: "Thất bại",
    cskh_l1: "CSKH L1",
    cskh_l2: "CSKH L2",
    closed: "Đóng"
  }.freeze

  # Status colors for UI badges
  STATUS_COLORS = {
    new_contact: "bg-blue-100 text-blue-700",
    potential: "bg-teal-100 text-teal-700",
    in_progress: "bg-yellow-100 text-yellow-700",
    potential_old: "bg-orange-100 text-orange-700",
    closed_new: "bg-green-100 text-green-700",
    closed_old: "bg-green-100 text-green-700",
    failed: "bg-red-100 text-red-700",
    cskh_l1: "bg-purple-100 text-purple-700",
    cskh_l2: "bg-purple-100 text-purple-700",
    closed: "bg-gray-100 text-gray-700"
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
    %i[closed_new closed_old closed].include?(check_status.to_sym)
  end

  # Check if current status is failed
  def failed_state?
    status.to_sym == :failed
  end

  # Check if current status is CSKH
  def cskh_state?
    %i[cskh_l1 cskh_l2].include?(status.to_sym)
  end

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
