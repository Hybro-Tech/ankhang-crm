# frozen_string_literal: true

# TASK-019/020/021: Contacts Controller
# Manages customer contacts with role-based access control
# rubocop:disable Metrics/ClassLength
class ContactsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource except: %i[check_phone check_identity recent]
  before_action :set_filter_options, only: :index

  # GET /contacts
  def index
    @contacts = apply_filters(base_contacts_query)
    @contacts = @contacts.page(params[:page]).per(20)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show; end

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
      render :new, status: :unprocessable_content
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

  # POST /contacts/:id/pick - TASK-020: Pick unassigned contact
  # rubocop:disable Metrics/AbcSize
  def pick
    authorize! :pick, @contact

    if @contact.assign_to!(current_user)
      # Log activity for Sales Workspace
      ActivityLog.create(
        user: current_user,
        action: "contact.pick",
        subject: @contact,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      )

      respond_to do |format|
        format.html { redirect_to @contact, notice: t("contacts.assign.success") }
        format.turbo_stream { flash.now[:notice] = t("contacts.assign.success") }
      end
    else
      respond_to do |format|
        format.html { redirect_to contacts_path, alert: t("contacts.assign.already_assigned") }
        format.turbo_stream { flash.now[:alert] = t("contacts.assign.already_assigned") }
      end
    end
    # rubocop:enable Metrics/AbcSize
  end

  # GET /contacts/check_phone?phone=xxx - TASK-021: Real-time phone check
  def check_phone
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
    @identity_value = params[:phone].presence || params[:zalo_id].presence
    return unless @identity_value

    @contact = if params[:phone].present?
                 Contact.find_by(phone: params[:phone])
               elsif params[:zalo_id].present?
                 Contact.find_by(zalo_id: params[:zalo_id])
               end

    respond_to do |format|
      format.turbo_stream
    end
  end

  # GET /contacts/recent
  # TASK-049: Restore recent contacts list
  def recent
    @recent_contacts = current_user.created_contacts
                                   .includes(:service_type, :assigned_user)
                                   .order(created_at: :desc)
                                   .limit(10)

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_filter_options
    @teams = Team.order(:name)
    @service_types_filter = ServiceType.active.ordered
    @statuses = Contact.statuses.keys
  end

  def base_contacts_query
    @contacts
      .includes(:service_type, :team, :assigned_user, :creator)
      .order(Arel.sql("assigned_user_id IS NOT NULL, created_at DESC"))
  end

  def apply_filters(query)
    query = query.by_status(params[:status]) if params[:status].present?
    query = query.by_team(params[:team_id]) if params[:team_id].present?
    query = query.by_service_type(params[:service_type_id]) if params[:service_type_id].present?
    query = query.search(params[:q]) if params[:q].present?
    query
  end

  def contact_params
    params.expect(
      contact: %i[name phone email zalo_link zalo_id zalo_qr
                  service_type_id source status
                  team_id assigned_user_id next_appointment notes]
    )
  end
end
# rubocop:enable Metrics/ClassLength
