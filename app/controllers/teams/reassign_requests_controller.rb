# frozen_string_literal: true

# TASK-052: Teams ReassignRequests Controller
# Handles viewing and approving/rejecting reassign requests by Team Lead
module Teams
  class ReassignRequestsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_team_leader!
    before_action :set_reassign_request, only: %i[approve reject]

    # GET /teams/reassign_requests
    def index
      @status_filter = params[:status] || "pending"
      @reassign_requests = filtered_requests.includes(:contact, :from_user, :to_user, :requested_by)
                                            .order(created_at: :desc)
                                            .page(params[:page])
                                            .per(20)

      @counts = {
        all: requests_for_approver.count,
        pending: requests_for_approver.pending.count,
        processed: requests_for_approver.where(status: %i[approved rejected]).count
      }
    end

    # POST /teams/reassign_requests/:id/approve
    def approve
      @reassign_request.approve!(current_user)

      respond_to do |format|
        format.html { redirect_to teams_reassign_requests_path, notice: "Đã duyệt yêu cầu" }
        format.turbo_stream { flash.now[:notice] = "Đã duyệt yêu cầu" }
      end
    rescue StandardError => e
      respond_to do |format|
        format.html { redirect_to teams_reassign_requests_path, alert: "Lỗi: #{e.message}" }
        format.turbo_stream { flash.now[:alert] = "Lỗi: #{e.message}" }
      end
    end

    # POST /teams/reassign_requests/:id/reject
    def reject
      rejection_reason = params[:rejection_reason]
      return respond_with_error("Vui lòng nhập lý do từ chối") if rejection_reason.blank?

      @reassign_request.reject!(current_user, rejection_reason)
      respond_with_success("Đã từ chối yêu cầu")
    rescue StandardError => e
      respond_with_error("Lỗi: #{e.message}")
    end

    private

    def respond_with_success(message)
      respond_to do |format|
        format.html { redirect_to teams_reassign_requests_path, notice: message }
        format.turbo_stream { flash.now[:notice] = message }
      end
    end

    def respond_with_error(message)
      respond_to do |format|
        format.html { redirect_to teams_reassign_requests_path, alert: message }
        format.turbo_stream { flash.now[:alert] = message }
      end
    end

    def authorize_team_leader!
      return if current_user.super_admin? || current_user.team_leader?

      redirect_to root_path, alert: "Bạn không có quyền truy cập khu vực này."
    end

    def set_reassign_request
      @reassign_request = requests_for_approver.find(params[:id])
    end

    def requests_for_approver
      ReassignRequest.for_approver(current_user)
    end

    def filtered_requests
      case @status_filter
      when "pending"
        requests_for_approver.pending
      when "processed"
        requests_for_approver.where(status: %i[approved rejected])
      else
        requests_for_approver
      end
    end
  end
end
