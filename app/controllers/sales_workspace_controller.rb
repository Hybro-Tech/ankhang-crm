# frozen_string_literal: true

# Sales Workspace Controller
# Main working screen for Sales staff - optimized for productivity
class SalesWorkspaceController < ApplicationController
  include SalesKanbanConcern

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

  # GET /sales/workspace/tab_in_progress (Turbo Frame)
  def tab_in_progress
    load_tab_data(:in_progress)
    render partial: "contact_list", locals: { contacts: @contacts, tab: :in_progress }, layout: false
  end

  # GET /sales/workspace/preview/:id (Turbo Frame)
  def preview
    @contact = Contact.find(params[:id])
    render partial: "contact_preview", locals: { contact: @contact }
  end

  # Kanban methods are in SalesKanbanConcern

  private

  def authorize_sale_user
    # Allow Sale and Admin roles (use code for stable checks)
    return if current_user.has_role_code?("sale") || current_user.super_admin?

    redirect_to root_path, alert: "Bạn không có quyền truy cập khu vực này."
  end

  def load_kpis
    user_teams = current_user.teams.pluck(:id)

    @kpis = {
      new_contacts: Contact.status_new_contact.where(team_id: user_teams).count,
      needs_update: current_user.assigned_contacts.needs_info_update.count,
      in_progress: current_user.assigned_contacts.where(status: %i[potential in_progress]).count,
      appointments_today: current_user.assigned_contacts
                                      .where(next_appointment: Time.current.all_day)
                                      .count
    }
  end

  # rubocop:disable Metrics/MethodLength
  def load_tab_data(tab)
    user_teams = current_user.teams.pluck(:id)

    @contacts = case tab
                when :new_contacts
                  # Contacts in user's teams that are unassigned (new)
                  Contact.status_new_contact
                         .where(team_id: user_teams)
                         .order(created_at: :desc)
                         .limit(20)
                when :needs_update
                  # Contacts assigned to user that need info update
                  current_user.assigned_contacts
                              .needs_info_update
                              .order(updated_at: :asc)
                              .limit(20)
                when :in_progress
                  # Contacts being worked on by user
                  current_user.assigned_contacts
                              .where(status: %i[potential in_progress])
                              .order(updated_at: :desc)
                              .limit(20)
                else
                  Contact.none
                end

    @current_tab = tab
  end
  # rubocop:enable Metrics/MethodLength

  def load_context_panel
    # Appointments for today and tomorrow
    @appointments = current_user.assigned_contacts
                                .where(next_appointment: Time.current.beginning_of_day...2.days.from_now.end_of_day)
                                .order(next_appointment: :asc)
                                .limit(5)

    # Today's activities for the current user (only customer-related work)
    @today_activities = ActivityLog.where(user_id: current_user.id)
                                   .where(created_at: Time.current.all_day)
                                   .where("action LIKE ?", "contact.%")
                                   .order(created_at: :desc)
                                   .limit(10)
  end
end
