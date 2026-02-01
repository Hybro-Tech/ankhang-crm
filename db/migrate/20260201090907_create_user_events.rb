# frozen_string_literal: true

# TASK-LOGGING: Tier 2 - User Event Logs
# Tracks all user requests: page views, API calls, AJAX, downloads
class CreateUserEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :user_events do |t|
      t.references :user, null: true, foreign_key: true  # null for anonymous
      t.string :event_type, limit: 20                    # page_view, api_call, form_submit, download
      t.string :path, limit: 500
      t.string :method, limit: 10                        # GET, POST, PUT, DELETE
      t.string :controller, limit: 100
      t.string :action, limit: 50
      t.json :params                                     # Sanitized request params
      t.integer :response_status, limit: 2               # 200, 404, 500...
      t.integer :duration_ms
      t.string :ip_address, limit: 45
      t.text :user_agent
      t.string :session_id, limit: 100
      t.string :request_id, limit: 50

      t.timestamps
    end

    # Indexes for common queries
    add_index :user_events, %i[user_id created_at]
    add_index :user_events, %i[event_type created_at]
    add_index :user_events, :created_at
    add_index :user_events, :request_id
  end
end
