# frozen_string_literal: true

# TASK-061: Create provinces table for 63 Vietnamese provinces
class CreateProvinces < ActiveRecord::Migration[7.1]
  def change
    create_table :provinces do |t|
      t.string :name, null: false, limit: 100
      t.string :code, null: false, limit: 20
      t.integer :position, default: 0
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :provinces, :name, unique: true
    add_index :provinces, :code, unique: true
    add_index :provinces, :active
    add_index :provinces, :position
  end
end
