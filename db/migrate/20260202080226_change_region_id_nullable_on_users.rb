# frozen_string_literal: true

# Fix region_id to be nullable for existing users
class ChangeRegionIdNullableOnUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :region_id, true
  end
end
