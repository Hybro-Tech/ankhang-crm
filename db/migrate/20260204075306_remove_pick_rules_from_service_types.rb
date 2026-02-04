# frozen_string_literal: true

# TASK-060: Remove pick rules from ServiceType
# These columns are being moved to UserServiceTypeLimit for per-user configuration
# pick_cooldown_minutes is now an ENV variable (PICK_COOLDOWN_MINUTES)
class RemovePickRulesFromServiceTypes < ActiveRecord::Migration[7.1]
  def change
    remove_column :service_types, :max_pick_per_day, :integer, default: 20, null: false
    remove_column :service_types, :pick_cooldown_minutes, :integer, default: 5, null: false
  end
end
