# frozen_string_literal: true

# TASK-052: Sales Workspace KPI calculations
# TASK-064: Updated for simplified status (4 states)
# Extracted from SalesWorkspaceController to reduce class length
module SalesWorkspaceKpisConcern
  extend ActiveSupport::Concern

  private

  def load_kpis
    @kpis = {
      new_contacts: kpi_new_contacts,
      needs_update: kpi_needs_update,
      potential: kpi_potential,
      appointments_today: kpi_appointments_today
    }

    # TASK-052: Add pending requests count for Team Leaders
    @kpis[:pending_requests] = kpi_pending_requests if current_user.team_leader?
  end

  def kpi_new_contacts
    Contact.status_new_contact.where(team_id: user_team_ids).visible_to(current_user).count
  end

  def kpi_needs_update
    current_user.assigned_contacts.needs_info_update.count
  end

  # TASK-064: Simplified - only potential status now
  def kpi_potential
    current_user.assigned_contacts.status_potential.count
  end

  def kpi_appointments_today
    current_user.assigned_contacts.where(next_appointment: Time.current.all_day).count
  end

  def kpi_pending_requests
    ReassignRequest.for_approver(current_user).pending.count
  end

  def user_team_ids
    @user_team_ids ||= current_user.teams.pluck(:id)
  end
end
