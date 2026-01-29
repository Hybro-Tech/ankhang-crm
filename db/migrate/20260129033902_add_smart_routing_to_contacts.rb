# TASK-053: Smart Routing - Progressive visibility for contacts
# visible_to_user_ids: JSON array of user IDs who can see this contact
# last_expanded_at: When visibility was last expanded (for background job)
class AddSmartRoutingToContacts < ActiveRecord::Migration[8.0]
  def change
    add_column :contacts, :visible_to_user_ids, :json
    add_column :contacts, :last_expanded_at, :datetime

    # Index for background job that expands visibility
    add_index :contacts, :last_expanded_at, where: "status = 'new' AND assigned_user_id IS NULL"
  end
end
