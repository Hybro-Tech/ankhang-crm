# frozen_string_literal: true

# TASK-063: Add province and address to contacts
# Also add last_interaction_at for CSKH blacklist tracking
class AddProvinceToContacts < ActiveRecord::Migration[7.1]
  def change
    add_reference :contacts, :province, foreign_key: true, null: true
    add_column :contacts, :address, :string
    add_column :contacts, :last_interaction_at, :datetime
    add_index :contacts, :last_interaction_at
  end
end
