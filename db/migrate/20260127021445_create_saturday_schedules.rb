class CreateSaturdaySchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :saturday_schedules do |t|
      t.date :date, null: false
      t.string :description

      t.timestamps
    end
    add_index :saturday_schedules, :date, unique: true

    create_table :saturday_schedule_users do |t|
      t.references :saturday_schedule, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :saturday_schedule_users, [:saturday_schedule_id, :user_id], unique: true, name: 'index_saturday_schedule_users_on_schedule_and_user'
  end
end
