# frozen_string_literal: true

# TASK-009: Migration bảng Teams
# Tạo bảng teams để phân chia nhân viên theo vùng/nhóm
class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams do |t|
      t.string :name, null: false, limit: 100
      t.text :description
      t.string :region, limit: 50
      t.bigint :manager_id, comment: 'FK to users.id - Team manager'

      t.timestamps
    end

    # Indexes
    add_index :teams, :name, unique: true
    add_index :teams, :region
    add_index :teams, :manager_id

    # Change users.team_id from integer to bigint for consistency
    change_column :users, :team_id, :bigint

    # Add index on users.team_id if not exists
    add_index :users, :team_id unless index_exists?(:users, :team_id)

    # Foreign Keys (handle circular dependency carefully)
    # 1. FK from users.team_id -> teams.id
    add_foreign_key :users, :teams, column: :team_id, on_delete: :nullify

    # 2. FK from teams.manager_id -> users.id
    add_foreign_key :teams, :users, column: :manager_id, on_delete: :nullify
  end
end
