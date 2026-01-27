class AddIndexToContactsZaloId < ActiveRecord::Migration[8.0]
  def change
    remove_index :contacts, :zalo_id if index_exists?(:contacts, :zalo_id)
    add_index :contacts, :zalo_id, unique: true
  end
end
