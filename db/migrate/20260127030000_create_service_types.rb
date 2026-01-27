# frozen_string_literal: true

# TASK-019: Create ServiceType (Loại nhu cầu) table
# This is a prerequisite for Contact model's service_type_id foreign key
class CreateServiceTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :service_types do |t|
      t.string :name, null: false, limit: 100
      t.text :description
      t.bigint :team_id, comment: "Default team for Smart Routing"
      t.boolean :active, default: true, null: false
      t.integer :position, default: 0, null: false, comment: "For ordering in dropdowns"

      t.timestamps
    end

    add_index :service_types, :name, unique: true
    add_index :service_types, :active
    add_index :service_types, :team_id
    add_foreign_key :service_types, :teams, column: :team_id, on_delete: :nullify
  end
end
