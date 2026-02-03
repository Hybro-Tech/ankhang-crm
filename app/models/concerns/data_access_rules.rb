# frozen_string_literal: true

# TASK-RBAC: Concern for data-level access rules
# Defines conditional abilities for Contacts and feature access
# TASK-PERF: Optimized to use cached permissions
module DataAccessRules
  extend ActiveSupport::Concern

  private

  # Define data-level access rules for Contacts
  # Uses CanCanCan conditions to enable accessible_by filtering
  # TASK-PERF: Use cached effective_permission_codes instead of has_permission?
  def define_contact_access(user)
    permission_codes = user.effective_permission_codes

    # contacts.view_all = See all contacts
    if permission_codes.include?("contacts.view_all")
      can :read, Contact
      return
    end

    # contacts.view_team = See contacts in user's teams
    can :read, Contact, team_id: user.team_ids if permission_codes.include?("contacts.view_team")

    # contacts.view_own = See only assigned or created contacts
    return unless permission_codes.include?("contacts.view_own")

    can :read, Contact, assigned_user_id: user.id
    can :read, Contact, created_by_id: user.id
  end

  # Define feature access rules
  # TASK-PERF: Use cached permissions and pre-loaded managed_team
  def define_feature_access(user)
    permission_codes = user.effective_permission_codes

    # Sales Workspace access
    can :access, :sales_workspace if permission_codes.include?("sales_workspace.access")

    # Reassign request approval (permission OR team leader)
    # TASK-PERF: managed_team is pre-loaded by Ability
    return unless permission_codes.include?("reassign_requests.approve") || user.managed_team.present?

    can :approve,
        ReassignRequest
  end
end
