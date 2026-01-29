class AddPickRulesToServiceTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :service_types, :max_pick_per_day, :integer, default: 20, null: false
    add_column :service_types, :pick_cooldown_minutes, :integer, default: 5, null: false
  end
end
