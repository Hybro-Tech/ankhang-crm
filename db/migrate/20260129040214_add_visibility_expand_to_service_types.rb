# TASK-053: Move visibility_expand_minutes to ServiceType
# Each service type can have different visibility expansion rate
class AddVisibilityExpandToServiceTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :service_types, :visibility_expand_minutes, :integer, default: 2, null: false
  end
end
