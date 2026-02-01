class CreateReassignRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :reassign_requests do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :from_user, null: false, foreign_key: { to_table: :users }
      t.references :to_user, foreign_key: { to_table: :users }  # NULLABLE for unassign
      t.references :requested_by, null: false, foreign_key: { to_table: :users }
      t.references :approved_by, foreign_key: { to_table: :users }

      t.integer :request_type, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.text :reason, null: false
      t.text :rejection_reason
      t.datetime :decided_at

      t.timestamps
    end

    add_index :reassign_requests, %i[contact_id status]
    add_index :reassign_requests, %i[from_user_id status]
  end
end
