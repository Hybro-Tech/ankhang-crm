class AddUseSmartRoutingToServiceTypes < ActiveRecord::Migration[8.0]
  def change
    add_column :service_types, :use_smart_routing, :boolean, default: true, null: false
  end
end
