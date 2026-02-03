# frozen_string_literal: true

# TASK-019/020/021: Contacts Controller
# Manages customer contacts with role-based access control
# rubocop:disable Metrics/ClassLength
class ContactsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource except: %i[check_phone check_identity recent update_status]
  before_action :set_contact, only: [:update_status]
  before_action :set_filter_options, only: :index

  # GET /contacts
  def index
    @contacts = apply_filters(base_contacts_query)
    per_page = params[:per_page].presence || 10
    @contacts = @contacts.page(params[:page]).per(per_page)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    @interactions = @contact.interactions.includes(:user).recent
  end

  def new
    @contact = Contact.new
    @service_types = ServiceType.for_dropdown
  end

  def edit
    @service_types = ServiceType.for_dropdown
  end

  def create
    @contact = Contact.new(contact_params)
    @contact.created_by_id = current_user.id

    if @contact.save
      respond_to do |format|
        format.html { redirect_to contacts_path, notice: t(".success") }
        # TASK-049: Support inline creation for Call Center Dashboard
        format.turbo_stream
      end
    else
      @service_types = ServiceType.for_dropdown
      # TASK-049: Handle validation errors for Call Center Dashboard (Inline Form)
      if request.headers["Turbo-Frame"] == "new_contact_form"
        render partial: "contacts/form_call_center", locals: { contact: @contact }, status: :unprocessable_content
      else
        render :new, status: :unprocessable_content
      end
    end
  end

  def update
    if @contact.update(contact_params)
      redirect_to @contact, notice: t(".success")
    else
      @service_types = ServiceType.for_dropdown
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_path, notice: t(".success")
  end

  # POST /contacts/:id/pick - TASK-022: Pick Mechanism with Eligibility Check
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def pick
    authorize! :pick, @contact

    # TASK-022: Check eligibility before picking
    eligibility = PickEligibilityService.check(current_user, @contact)

    unless eligibility.eligible
      respond_to do |format|
        format.html { redirect_back_or_to(contacts_path, alert: eligibility.reason) }
        format.turbo_stream do
          flash.now[:alert] = eligibility.reason
          render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash_messages")
        end
      end
      return
    end

    # TASK-022: Use database lock to prevent race condition
    @contact.with_lock do
      # Double check - contact could have been picked while waiting for lock
      unless @contact.pickable?
        respond_to do |format|
          format.html { redirect_to contacts_path, alert: t("contacts.assign.already_assigned") }
          format.turbo_stream do
            flash.now[:alert] = t("contacts.assign.already_assigned")
            render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flash_messages")
          end
        end
        return
      end

      @contact.assign_to!(current_user)

      # Log activity for Sales Workspace
      ActivityLog.create(
        user: current_user,
        action: "contact.pick",
        subject: @contact,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )
    end

    respond_to do |format|
      format.html { redirect_to @contact, notice: t("contacts.assign.success") }
      format.turbo_stream { redirect_to @contact, notice: t("contacts.assign.success"), status: :see_other }
    end
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  # GET /contacts/check_phone?phone=xxx - TASK-021: Real-time phone check
  def check_phone
    authorize! :create, Contact
    phone = Contact.normalize_phone_number(params[:phone])

    if phone.length < 10
      render json: { exists: false, message: nil }
    elsif Contact.phone_exists?(phone)
      existing = Contact.find_by(phone: phone)
      render json: {
        exists: true,
        message: "SĐT này đã tồn tại: #{existing.name} (#{existing.code})",
        contact_id: existing.id,
        contact_name: existing.name,
        contact_code: existing.code
      }
    else
      render json: { exists: false, message: "SĐT chưa có trong hệ thống" }
    end
  end

  # GET /contacts/check_identity?phone=... or ?zalo_id=...
  # TASK-049: Context Awareness
  def check_identity
    authorize! :create, Contact
    @identity_value = params[:phone].presence || params[:zalo_id].presence
    return unless @identity_value

    @contact = find_contact_by_identity

    respond_to do |format|
      format.turbo_stream
      format.json { render json: identity_check_response }
    end
  end

  # GET /contacts/recent
  # TASK-049: Restore recent contacts list
  def recent
    authorize! :read, Contact
    @recent_contacts = current_user.created_contacts
                                   .includes(:service_type, :assigned_user)
                                   .order(created_at: :desc)
                                   .limit(10)

    respond_to do |format|
      format.turbo_stream
    end
  end

  # POST /contacts/:id/update_status
  # TASK-051: State Machine - Change contact status
  def update_status
    authorize! :edit, @contact
    new_status = params[:new_status]&.to_sym

    if new_status.blank?
      respond_with_error("Vui lòng chọn trạng thái mới")
      return
    end

    begin
      @contact.transition_to!(new_status, user: current_user, reason: params[:reason])
      @old_status = @contact.status_was
      @new_status = new_status

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @contact, notice: t("contacts.status_updated") }
      end
    rescue StatusMachine::InvalidTransitionError => e
      respond_with_error(e.message)
    end
  end

  private

  def set_filter_options
    @teams = Team.order(:name)
    @service_types_filter = ServiceType.active.ordered
    @statuses = Contact.statuses.keys
    # TASK-052: Add users filter for Admin
    @users_filter = User.active.order(:name) if current_user.super_admin?
  end

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def base_contacts_query
    # TASK-RBAC: Use accessible_by for permission-based filtering
    # This uses rules defined in Ability#define_contact_access
    Contact.accessible_by(current_ability)
           .includes(:service_type, :team, :assigned_user, :creator)
           .order(created_at: :desc)
  end

  def apply_filters(query)
    query = apply_basic_filters(query)
    apply_admin_filters(query)
  end

  def apply_basic_filters(query)
    query = query.by_status(params[:status]) if params[:status].present?
    query = query.by_team(params[:team_id]) if params[:team_id].present?
    query = query.by_service_type(params[:service_type_id]) if params[:service_type_id].present?
    query = query.search(params[:q]) if params[:q].present?
    query
  end

  def apply_admin_filters(query)
    # TASK-052: Filter by assigned user (Admin only)
    return query unless current_user.super_admin? && params[:user_id].present?

    query.where(assigned_user_id: params[:user_id])
  end

  def contact_params
    params.expect(
      contact: %i[name phone email zalo_link zalo_id zalo_qr
                  service_type_id source_id status
                  team_id assigned_user_id next_appointment notes]
    )
  end

  def respond_with_error(message)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "status_changer",
          partial: "contacts/partials/status_changer",
          locals: { contact: @contact, error: message }
        )
      end
      format.html { redirect_to @contact, alert: message }
    end
  end

  def find_contact_by_identity
    return Contact.find_by(phone: params[:phone]) if params[:phone].present?
    return Contact.find_by(zalo_id: params[:zalo_id]) if params[:zalo_id].present?

    nil
  end

  def identity_check_response
    {
      exists: @contact.present?,
      contact: @contact&.as_json(only: %i[id name code status]),
      message: @contact ? "Đã tồn tại trong hệ thống" : "Có thể thêm mới"
    }
  end
end
# rubocop:enable Metrics/ClassLength
