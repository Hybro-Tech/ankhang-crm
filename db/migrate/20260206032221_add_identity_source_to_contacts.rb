class AddIdentitySourceToContacts < ActiveRecord::Migration[8.0]
  def change
    add_column :contacts, :identity_source, :string, limit: 10, default: 'phone', null: false
  end
end
