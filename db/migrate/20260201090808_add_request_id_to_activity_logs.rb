class AddRequestIdToActivityLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :activity_logs, :request_id, :string
  end
end
