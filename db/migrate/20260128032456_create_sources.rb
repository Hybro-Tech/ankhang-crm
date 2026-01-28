class CreateSources < ActiveRecord::Migration[8.0]
  def up
    create_table :sources do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :active, default: true, null: false
      t.integer :position, default: 0, null: false

      t.timestamps
    end
    add_index :sources, :name, unique: true

    add_reference :contacts, :source, foreign_key: true

    # Local model for seeding
    source_model = Class.new(ActiveRecord::Base) { self.table_name = "sources" }
    
    # Mapping from enum value to Name
    enum_map = {
      0 => "Ladi Zalo/Hotline",
      1 => "Facebook",
      2 => "Google",
      3 => "Giới thiệu",
      4 => "Khác"
    }

    enum_map.each do |val, name|
      source_model.create!(name: name, position: val, active: true)
      
      # Migrate existing data
      new_source_id = source_model.find_by(name: name).id
      execute("UPDATE contacts SET source_id = #{new_source_id} WHERE source = #{val}")
    end

    remove_column :contacts, :source
  end

  def down
    add_column :contacts, :source, :integer, default: 0, null: false
    # Reverse logic omitted for brevity/safety
    remove_reference :contacts, :source
    drop_table :sources
  end
end
