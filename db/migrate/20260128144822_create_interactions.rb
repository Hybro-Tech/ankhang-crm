# TASK-023: Interaction model for contact care history
class CreateInteractions < ActiveRecord::Migration[8.0]
  def change
    create_table :interactions do |t|
      t.references :contact, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :content, null: false
      t.integer :interaction_method, null: false, default: 0

      t.timestamps
    end

    add_index :interactions, %i[contact_id created_at]
  end
end
