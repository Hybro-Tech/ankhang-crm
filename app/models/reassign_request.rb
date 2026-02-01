# frozen_string_literal: true

# TASK-052: ReassignRequest model for Admin re-assign/unassign workflow
# Tracks requests to transfer contacts between sales reps with approval workflow
class ReassignRequest < ApplicationRecord
  # === Enums ===
  enum :request_type, { reassign: 0, unassign: 1 }
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  # === Associations ===
  belongs_to :contact
  belongs_to :from_user, class_name: "User"
  belongs_to :to_user, class_name: "User", optional: true
  belongs_to :requested_by, class_name: "User"
  belongs_to :approved_by, class_name: "User", optional: true

  # === Validations ===
  validates :reason, presence: true
  validates :to_user, presence: true, if: :reassign?
  validates :rejection_reason, presence: true, if: :rejected?
  validate :cannot_reassign_to_same_user, if: -> { reassign? && to_user_id.present? }
  validate :no_pending_request_exists, on: :create

  # === Callbacks ===
  before_validation :set_request_type
  after_create_commit :notify_stakeholders

  # === Scopes ===
  scope :for_approver, lambda { |user|
    joins(contact: :team)
      .where(teams: { manager_id: user.id })
      .distinct
  }

  # === Instance Methods ===

  # Approve the request
  # @param approver [User] The user who approves
  def approve!(approver)
    transaction do
      update!(
        status: :approved,
        approved_by: approver,
        decided_at: Time.current
      )
      ReassignService.new(self).execute
      ReassignRequestNotificationJob.perform_later(id, "approved")
    end
  end

  # Reject the request
  # @param approver [User] The user who rejects
  # @param reason [String] The rejection reason
  def reject!(approver, reason)
    update!(
      status: :rejected,
      approved_by: approver,
      rejection_reason: reason,
      decided_at: Time.current
    )
    ReassignRequestNotificationJob.perform_later(id, "rejected")
  end

  # Get the approver (Lead/Manager of the team)
  # @return [User, nil]
  def approver
    from_user.teams.first&.manager
  end

  # Human-readable request type
  def request_type_label
    reassign? ? "Chuyển KH" : "Gỡ KH"
  end

  # Status badge color
  STATUS_COLORS = {
    "pending" => "yellow",
    "approved" => "green",
    "rejected" => "red"
  }.freeze

  def status_color
    STATUS_COLORS[status]
  end

  private

  def set_request_type
    self.request_type = to_user_id.present? ? :reassign : :unassign
  end

  def cannot_reassign_to_same_user
    errors.add(:to_user_id, "không thể chuyển cho chính người đang sở hữu") if from_user_id == to_user_id
  end

  def no_pending_request_exists
    return unless ReassignRequest.pending.exists?(contact_id: contact_id)

    errors.add(:contact, "đã có yêu cầu chuyển đang chờ duyệt")
  end

  def notify_stakeholders
    ReassignRequestNotificationJob.perform_later(id, "created")
  end
end
