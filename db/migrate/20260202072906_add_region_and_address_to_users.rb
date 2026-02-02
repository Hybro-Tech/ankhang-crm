# frozen_string_literal: true

class AddRegionAndAddressToUsers < ActiveRecord::Migration[8.0]
  def change
    # region_id already added in a failed run, only add if not exists
    unless column_exists?(:users, :region_id)
      add_reference :users, :region, null: true, foreign_key: true
    end

    unless column_exists?(:users, :address)
      add_column :users, :address, :text
    end
  end
end
