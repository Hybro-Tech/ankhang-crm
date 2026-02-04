# frozen_string_literal: true

# TASK-062: Create user_service_type_limits for per-user pick limits
class CreateUserServiceTypeLimits < ActiveRecord::Migration[7.1]
  def change
    create_table :user_service_type_limits do |t|
      t.references :user, null: false, foreign_key: true
      t.references :service_type, null: false, foreign_key: true
      t.integer :max_pick_per_day, null: false, default: 10

      t.timestamps
    end

    add_index :user_service_type_limits, %i[user_id service_type_id], unique: true, name: "idx_user_service_type_limits_unique"
  end
end
