# frozen_string_literal: true

# Concern for handling Sales Kanban logic
module SalesKanbanConcern
  extend ActiveSupport::Concern

  included do
    # Helpers for Kanban logic can be here if needed
  end

  def kanban
    load_kanban_data
  end

  def update_status
    @contact = current_user.assigned_contacts.find(params[:id])
    new_status = params[:status]

    if valid_status?(new_status) && @contact.update(status: new_status)
      handle_update_success
    else
      handle_update_failure
    end
  end

  private

  def valid_status?(status)
    Contact.statuses.keys.include?(status)
  end

  def handle_update_success
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("kanban_card_#{@contact.id}") }
      format.html { redirect_to sales_kanban_path, notice: "Đã cập nhật trạng thái." }
    end
  end

  def handle_update_failure
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("kanban_card_#{@contact.id}",
                                                  partial: "sales_workspace/kanban_card",
                                                  locals: { contact: @contact })
      end
      format.html { redirect_to sales_kanban_path, alert: "Lỗi khi cập nhật." }
    end
  end

  def load_kanban_data
    scope = current_user.assigned_contacts.includes(:service_type)
    @kanban_columns = {
      potential: { title: "Tiềm năng", icon: "fa-user-plus", color: "orange",
                   contacts: scope.status_potential.limit(20) },
      in_progress: { title: "Đang đàm phán", icon: "fa-comments", color: "blue",
                     contacts: scope.status_in_progress.limit(20) },
      closed_new: { title: "Chốt thành công", icon: "fa-check-circle", color: "green",
                    contacts: scope.status_closed_new.limit(20) },
      failed: { title: "Thất bại", icon: "fa-times-circle", color: "red",
                contacts: scope.status_failed.limit(20) }
    }
  end
end
