class CreateTeamMembers < ActiveRecord::Migration[8.0]
  def up
    create_table :team_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end

    add_index :team_members, [:user_id, :team_id], unique: true

    # Data Migration
    execute <<-SQL
      INSERT INTO team_members (user_id, team_id, created_at, updated_at)
      SELECT id, team_id, NOW(), NOW()
      FROM users
      WHERE team_id IS NOT NULL
    SQL

    remove_reference :users, :team, foreign_key: true
  end

  def down
    add_reference :users, :team, foreign_key: true # { on_delete: :nullify } is default for previous definition? Need check.

    # Data Migration (Reverse - pick one team per user)
    # This is lossy if user has multiple teams, but for rollback of this specific migration (where we just started), 
    # we assume they came from single team state or we accept data loss on rollback for secondary teams.
    execute <<-SQL
      UPDATE users 
      JOIN (
        SELECT user_id, MIN(team_id) as team_id 
        FROM team_members 
        GROUP BY user_id
      ) as tm ON users.id = tm.user_id
      SET users.team_id = tm.team_id
    SQL

    drop_table :team_members
  end
end
