# frozen_string_literal: true

class CreateRegions < ActiveRecord::Migration[8.0]
  def change
    create_table :regions do |t|
      t.string :name, null: false, limit: 100
      t.string :code, null: false, limit: 20
      t.text :description
      t.integer :position, default: 0
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :regions, :code, unique: true
    add_index :regions, :name, unique: true
    add_index :regions, :position
    add_index :regions, :active
  end
end
