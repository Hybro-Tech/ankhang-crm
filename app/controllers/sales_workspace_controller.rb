# frozen_string_literal: true

# Sales Workspace Controller
# Main working screen for Sales staff - optimized for productivity
class SalesWorkspaceController < ApplicationController
  include SalesKanbanConcern
  include SalesWorkspaceKpisConcern

  before_action :authenticate_user!
  before_action :authorize_sale_user

  # GET /sales/workspace
  def show
    load_kpis
    load_tab_data(:new_contacts) # Default tab
    load_context_panel
  end

  # GET /sales/workspace/tab_new_contacts (Turbo Frame)
  def tab_new_contacts
    load_tab_data(:new_contacts)
    render partial: "contact_list", locals: { contacts: @contacts, tab: :new_contacts }, layout: false
  end

  # GET /sales/workspace/tab_needs_update (Turbo Frame)
  def tab_needs_update
    load_tab_data(:needs_update)
    render partial: "contact_list", locals: { contacts: @contacts, tab: :needs_update }, layout: false
  end

  # GET /sales/workspace/tab_potential (Turbo Frame)
  # TASK-064: Renamed from tab_in_progress
  def tab_potential
    load_tab_data(:potential)
    render partial: "contact_list", locals: { contacts: @contacts, tab: :potential }, layout: false
  end

  # GET /sales/workspace/tab_pending_requests (Turbo Frame) - TASK-052: For Team Leaders
  def tab_pending_requests
    unless current_user.team_leader?
      head :forbidden
      return
    end

    @reassign_requests = ReassignRequest.for_approver(current_user)
                                        .pending
                                        .includes(:contact, :from_user, :to_user, :requested_by)
                                        .order(created_at: :desc)
                                        .limit(20)
    render partial: "pending_requests_list", layout: false
  end

  # GET /sales/workspace/preview/:id (Turbo Frame)
  def preview
    @contact = Contact.find(params[:id])
    render partial: "contact_preview", locals: { contact: @contact }
  end

  # GET /sales/workspace/more_appointments (Turbo Frame - Load More)
  def more_appointments
    page = (params[:page] || 2).to_i
    per_page = 5
    offset = (page - 1) * per_page

    @appointments = appointments_base_query
                    .offset(offset)
                    .limit(per_page)

    @total_appointments = appointments_base_query.count
    @current_page = page
    @has_more = (offset + @appointments.size) < @total_appointments

    render partial: "more_appointments", layout: false
  end

  # Kanban methods are in SalesKanbanConcern

  private

  def authorize_sale_user
    # TASK-RBAC: Use CanCanCan authorization instead of role checks
    # Permission defined in Ability#define_feature_access
    authorize! :access, :sales_workspace
  rescue CanCan::AccessDenied
    redirect_to root_path, alert: "Bạn không có quyền truy cập khu vực này."
  end

  # rubocop:disable Metrics/MethodLength
  def load_tab_data(tab)
    @contacts = case tab
                when :new_contacts
                  # Contacts in user's teams that are unassigned (new) and visible to this user
                  Contact.status_new_contact
                         .where(team_id: user_team_ids)
                         .visible_to(current_user)
                         .order(created_at: :desc)
                         .limit(20)
                when :needs_update
                  # Contacts assigned to user that need info update
                  current_user.assigned_contacts
                              .needs_info_update
                              .order(updated_at: :asc)
                              .limit(20)
                when :potential
                  # TASK-064: Simplified - only potential status
                  current_user.assigned_contacts
                              .status_potential
                              .order(updated_at: :desc)
                              .limit(20)
                else
                  Contact.none
                end

    @current_tab = tab
  end
  # rubocop:enable Metrics/MethodLength

  def load_context_panel
    # Appointments (show first 5, load more on demand, no day limit)
    @appointments = appointments_base_query.limit(5)
    @total_appointments = appointments_base_query.count

    # Today's activities for the current user (only customer-related work)
    @today_activities = ActivityLog.where(user_id: current_user.id)
                                   .where(created_at: Time.current.all_day)
                                   .where("action LIKE ?", "contact.%")
                                   .order(created_at: :desc)
                                   .limit(10)
  end

  # Base query for appointments (reused for pagination)
  # Query from Interaction model to get ALL appointments, not just next_appointment
  def appointments_base_query
    Interaction.interaction_method_appointment
               .joins(:contact)
               .where(contacts: { assigned_user_id: current_user.id })
               .where(scheduled_at: Time.current.beginning_of_day..)
               .order(scheduled_at: :asc)
               .includes(:contact)
  end
end
