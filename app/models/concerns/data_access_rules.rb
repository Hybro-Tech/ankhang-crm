# frozen_string_literal: true

# TASK-RBAC: Concern for data-level access rules
# Defines conditional abilities for Contacts and feature access
module DataAccessRules
  extend ActiveSupport::Concern

  private

  # Define data-level access rules for Contacts
  # Uses CanCanCan conditions to enable accessible_by filtering
  def define_contact_access(user)
    # contacts.view_all = See all contacts
    if user.has_permission?("contacts.view_all")
      can :read, Contact
      return
    end

    # contacts.view_team = See contacts in user's teams
    can :read, Contact, team_id: user.team_ids if user.has_permission?("contacts.view_team")

    # contacts.view_own = See only assigned or created contacts
    return unless user.has_permission?("contacts.view_own")

    can :read, Contact, assigned_user_id: user.id
    can :read, Contact, created_by_id: user.id
  end

  # Define feature access rules
  def define_feature_access(user)
    # Sales Workspace access
    can :access, :sales_workspace if user.has_permission?("sales_workspace.access")

    # Reassign request approval (permission OR team leader)
    can :approve, ReassignRequest if user.has_permission?("reassign_requests.approve") || user.team_leader?
  end
end
