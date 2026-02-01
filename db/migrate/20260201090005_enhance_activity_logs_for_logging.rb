# frozen_string_literal: true

# Enhance activity_logs for comprehensive business logging
class EnhanceActivityLogsForLogging < ActiveRecord::Migration[8.0]
  def change
    change_table :activity_logs, bulk: true do |t|
      t.string :user_name, limit: 100       # Denormalized for faster display
      t.json :record_changes                # {old: {...}, new: {...}}
      t.string :category, limit: 20         # auth, contact, user, admin...
    end

    add_index :activity_logs, :category
    add_index :activity_logs, %i[category created_at]
  end
end
