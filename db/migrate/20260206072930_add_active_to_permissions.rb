class AddActiveToPermissions < ActiveRecord::Migration[8.0]
  def change
    add_column :permissions, :active, :boolean, default: true, null: false
  end
end
