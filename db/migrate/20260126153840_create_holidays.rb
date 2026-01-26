class CreateHolidays < ActiveRecord::Migration[8.0]
  def change
    create_table :holidays do |t|
      t.string :name
      t.date :date
      t.text :description

      t.timestamps
    end
    add_index :holidays, :date, unique: true
  end
end
