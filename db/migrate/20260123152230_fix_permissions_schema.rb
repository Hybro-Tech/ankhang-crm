class FixPermissionsSchema < ActiveRecord::Migration[7.1]
  def change
    # 1. Update Permissions Table
    # Removing subject/action, adding code/name/category
    if index_exists?(:permissions, [:subject, :action])
      remove_index :permissions, [:subject, :action]
    end
    
    remove_column :permissions, :subject, :string if column_exists?(:permissions, :subject)
    remove_column :permissions, :action, :string if column_exists?(:permissions, :action)
    
    add_column :permissions, :code, :string, null: false unless column_exists?(:permissions, :code)
    add_column :permissions, :name, :string unless column_exists?(:permissions, :name)
    add_column :permissions, :category, :string unless column_exists?(:permissions, :category)
    
    add_index :permissions, :code, unique: true unless index_exists?(:permissions, :code)

    # 2. Update User Permissions (Overrides)
    # Add created_by tracking
    unless column_exists?(:user_permissions, :created_by_id)
      add_column :user_permissions, :created_by_id, :bigint
      add_foreign_key :user_permissions, :users, column: :created_by_id
      add_index :user_permissions, :created_by_id
    end
  end
end
