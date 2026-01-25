# frozen_string_literal: true

# TASK-014: Activity Logs
# Ghi lại lịch sử hoạt động (Audit Trail)
class CreateActivityLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :activity_logs do |t|
      # User thực hiện hành động (có thể null nếu system hoặc unknown user)
      t.references :user, null: true, foreign_key: true

      # Hành động: login, logout, create, update, delete...
      t.string :action, null: false, limit: 50

      # Đối tượng bị tác động (polymorphic)
      # Có thể null nếu hành động không liên quan đối tượng cụ thể (e.g. login failed)
      t.references :subject, polymorphic: true, null: true

      # Chi tiết thay đổi hoặc metadata (JSON)
      t.json :details

      # Request info
      t.string :ip_address, limit: 45
      t.string :user_agent

      t.timestamps
    end

    # Indexes tối ưu cho việc tra cứu log
    add_index :activity_logs, :action
    add_index :activity_logs, [:user_id, :created_at] # Lịch sử của 1 user
    add_index :activity_logs, [:subject_type, :subject_id, :created_at], name: 'index_activity_logs_on_subject_and_created_at' # Lịch sử của 1 object
  end
end
