class AddDashboardTypeToRoles < ActiveRecord::Migration[8.0]
  def change
    add_column :roles, :dashboard_type, :integer, default: 0, null: false
  end
end
