# frozen_string_literal: true

# TASK-019: Create Contact table per SRS v2 Section 5.1
# Main entity for customer management in AnKhangCRM
class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      # Basic Info (SRS v2 Section 5.1)
      t.string :code, null: false, limit: 20, comment: "Auto-generated: KH2026-XXX"
      t.string :name, null: false, limit: 100, comment: "Tên KH (thường là tên Zalo)"
      t.string :phone, null: false, limit: 20, comment: "SĐT - Unique"
      t.string :email, limit: 100
      t.string :zalo_link, limit: 255, comment: "Link profile Zalo"

      # Business Info
      t.bigint :service_type_id, null: false, comment: "Loại nhu cầu - FK to service_types"
      t.integer :source, null: false, default: 0, comment: "Enum: Nguồn khách hàng"

      # Status (SRS v2 Section 5.3 - State Machine)
      t.integer :status, null: false, default: 0, comment: "Enum: Trạng thái contact"

      # Assignment
      t.bigint :team_id, comment: "Team được phân (từ loại nhu cầu)"
      t.bigint :assigned_user_id, comment: "Sale được gán"
      t.bigint :created_by_id, null: false, comment: "Người tạo (Tổng đài)"

      # Tracking
      t.datetime :assigned_at, comment: "Thời điểm gán cho Sale"
      t.datetime :next_appointment, comment: "Lịch hẹn tiếp theo"
      t.text :notes, comment: "Ghi chú tổng quát"

      # Timestamps
      t.datetime :closed_at, comment: "Thời điểm chốt/đóng"
      t.timestamps
    end

    # Primary indexes for searching
    add_index :contacts, :code, unique: true
    add_index :contacts, :phone, unique: true
    add_index :contacts, :status
    add_index :contacts, :source

    # Foreign key indexes
    add_index :contacts, :service_type_id
    add_index :contacts, :team_id
    add_index :contacts, :assigned_user_id
    add_index :contacts, :created_by_id

    # Composite indexes for common queries
    add_index :contacts, %i[status team_id], name: "index_contacts_on_status_and_team"
    add_index :contacts, %i[assigned_user_id status], name: "index_contacts_on_assignee_and_status"
    add_index :contacts, %i[team_id created_at], name: "index_contacts_on_team_and_created_at"
    add_index :contacts, :next_appointment, name: "index_contacts_on_next_appointment"

    # Foreign keys
    add_foreign_key :contacts, :service_types, column: :service_type_id
    add_foreign_key :contacts, :teams, column: :team_id, on_delete: :nullify
    add_foreign_key :contacts, :users, column: :assigned_user_id, on_delete: :nullify
    add_foreign_key :contacts, :users, column: :created_by_id
  end
end
