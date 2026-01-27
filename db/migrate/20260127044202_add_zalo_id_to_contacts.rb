class AddZaloIdToContacts < ActiveRecord::Migration[8.0]
  def change
    add_column :contacts, :zalo_id, :string
    add_index :contacts, :zalo_id
  end
end
