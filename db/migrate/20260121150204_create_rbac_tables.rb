class CreateRbacTables < ActiveRecord::Migration[7.1]
  def change
    # 1. Roles Table
    create_table :roles do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :is_system, default: false

      t.timestamps
    end
    add_index :roles, :name, unique: true

    # 2. Permissions Table
    create_table :permissions do |t|
      t.string :subject, null: false # Resource name (e.g., 'Contact')
      t.string :action, null: false  # Action (e.g., 'read', 'create')
      t.text :description

      t.timestamps
    end
    add_index :permissions, [:subject, :action], unique: true

    # 3. Role Permissions Join Table
    create_table :role_permissions do |t|
      t.references :role, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true

      t.timestamps
    end
    add_index :role_permissions, [:role_id, :permission_id], unique: true

    # 4. User Roles Join Table
    create_table :user_roles do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true

      t.timestamps
    end
    add_index :user_roles, [:user_id, :role_id], unique: true

    # 5. User Permissions Override Table
    create_table :user_permissions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true
      t.boolean :granted, default: true # True = Allow, False = Deny

      t.timestamps
    end
    add_index :user_permissions, [:user_id, :permission_id], unique: true
  end
end
