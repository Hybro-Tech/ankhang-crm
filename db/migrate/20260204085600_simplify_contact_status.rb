# frozen_string_literal: true

# TASK-064: Simplify Contact status (10 → 4)
# New statuses: new_contact(0), potential(1), failed(2), closed(3)
#
# Migration mapping:
# - new_contact(0) → new_contact(0)
# - potential(1), in_progress(2), potential_old(3) → potential(1)
# - closed_new(4), closed_old(5), cskh_l1(7), cskh_l2(8), closed(9) → closed(3)
# - failed(6) → failed(2)
class SimplifyContactStatus < ActiveRecord::Migration[7.1]
  def up
    # Step 1: Map old values to new values
    # Using raw SQL to avoid model validations during migration

    # potential(1), in_progress(2), potential_old(3) → potential(1)
    execute <<-SQL.squish
      UPDATE contacts SET status = 1 WHERE status IN (1, 2, 3)
    SQL

    # failed(6) → failed(2)
    execute <<-SQL.squish
      UPDATE contacts SET status = 2 WHERE status = 6
    SQL

    # closed_new(4), closed_old(5), cskh_l1(7), cskh_l2(8), closed(9) → closed(3)
    execute <<-SQL.squish
      UPDATE contacts SET status = 3 WHERE status IN (4, 5, 7, 8, 9)
    SQL

    # new_contact(0) stays as 0 - no change needed
  end

  def down
    # Reversing this migration is not fully possible since we lose granularity
    # We can only restore to a reasonable default state

    # closed(3) → closed_new(4) as default
    execute <<-SQL.squish
      UPDATE contacts SET status = 4 WHERE status = 3
    SQL

    # failed(2) → failed(6)
    execute <<-SQL.squish
      UPDATE contacts SET status = 6 WHERE status = 2
    SQL

    # potential(1) stays as potential(1) - no change needed
    # new_contact(0) stays as 0 - no change needed
  end
end
