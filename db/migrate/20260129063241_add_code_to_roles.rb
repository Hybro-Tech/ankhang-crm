# frozen_string_literal: true

class AddCodeToRoles < ActiveRecord::Migration[8.0]
  def up
    add_column :roles, :code, :string

    # Seed code for existing roles (separate statements for MySQL)
    execute "UPDATE roles SET code = 'super_admin' WHERE name = 'Super Admin'"
    execute "UPDATE roles SET code = 'sale' WHERE name = 'Sale'"
    execute "UPDATE roles SET code = 'call_center' WHERE name = 'Tổng Đài'"
    execute "UPDATE roles SET code = 'cskh' WHERE name = 'CSKH'"

    # Make code NOT NULL after seeding
    change_column_null :roles, :code, false
    add_index :roles, :code, unique: true
  end

  def down
    remove_index :roles, :code
    remove_column :roles, :code
  end
end
