# frozen_string_literal: true

# TASK-060: Remove remaining smart routing columns from service_types
# These settings are now:
# - use_smart_routing: Always true (3-layer routing for all)
# - visibility_expand_minutes: Read from ENV['VISIBILITY_EXPAND_MINUTES'] (default: 2)
class RemoveSmartRoutingFromServiceTypes < ActiveRecord::Migration[7.1]
  def change
    change_table :service_types, bulk: true do |t|
      t.remove :use_smart_routing, type: :boolean, default: true, null: false
      t.remove :visibility_expand_minutes, type: :integer, default: 2, null: false
    end
  end
end
