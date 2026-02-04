# frozen_string_literal: true

# TASK-061: Join table for Province <-> Region (many-to-many)
class CreateProvinceRegions < ActiveRecord::Migration[7.1]
  def change
    create_table :province_regions do |t|
      t.references :province, null: false, foreign_key: true
      t.references :region, null: false, foreign_key: true

      t.timestamps
    end

    add_index :province_regions, %i[province_id region_id], unique: true
  end
end
