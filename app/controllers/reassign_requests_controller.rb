# frozen_string_literal: true

# TASK-052: ReassignRequests Controller (Refactored from Admin namespace)
# Handles creation of reassign/unassign requests by Admin
# Route: /contacts/:contact_id/reassign_requests
class ReassignRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_contact
  before_action :authorize_admin!

  # GET /contacts/:contact_id/reassign_requests/new
  def new
    @users = available_users
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  # POST /contacts/:contact_id/reassign_requests
  def create
    @reassign_request = ReassignRequest.new(reassign_request_params)
    @reassign_request.contact = @contact
    @reassign_request.from_user = @contact.assigned_user
    @reassign_request.requested_by = current_user

    if @reassign_request.save
      respond_to do |format|
        format.html { redirect_to contacts_path, notice: "Yêu cầu đã được gửi đến Lead để phê duyệt" }
        format.turbo_stream { flash.now[:notice] = "Yêu cầu đã được gửi đến Lead để phê duyệt" }
      end
    else
      @users = available_users
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
        format.turbo_stream { render :new, status: :unprocessable_content }
      end
    end
  end

  private

  def set_contact
    @contact = Contact.find(params[:contact_id])
  end

  def reassign_request_params
    params.expect(reassign_request: %i[to_user_id reason])
  end

  def available_users
    User.active.where.not(id: @contact.assigned_user_id).order(:name)
  end

  def authorize_admin!
    return if current_user.super_admin?

    redirect_to contacts_path, alert: "Bạn không có quyền thực hiện thao tác này"
  end
end
