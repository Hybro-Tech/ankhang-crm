# frozen_string_literal: true

# TASK-011: Thêm các fields cho Devise Authentication
# - username: cho phép login bằng username hoặc email
# - lockable: khóa tài khoản sau 5 lần login thất bại
# - trackable: theo dõi lịch sử đăng nhập
class AddDeviseFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    # Username for alternative login
    add_column :users, :username, :string, limit: 50
    add_index :users, :username, unique: true

    # Lockable (AUTH-005: Lock sau 5 lần fail, 15 phút)
    add_column :users, :failed_attempts, :integer, default: 0, null: false
    add_column :users, :unlock_token, :string
    add_index :users, :unlock_token, unique: true
    add_column :users, :locked_at, :datetime

    # Trackable (for activity logging)
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string
  end
end
