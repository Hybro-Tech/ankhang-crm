# frozen_string_literal: true

# TASK-LOGGING: Phase 3 - Archive Tables
# Stores historical logs for permanent retention
class CreateArchiveTables < ActiveRecord::Migration[8.0]
  def change
    # Archive table for Tier 1 - Business Activity Logs
    create_table :activity_log_archives do |t|
      t.bigint :user_id
      t.string :user_name, limit: 100
      t.string :action, limit: 50, null: false
      t.string :category, limit: 20
      t.string :subject_type
      t.bigint :subject_id
      t.json :details
      t.json :record_changes
      t.string :ip_address, limit: 45
      t.string :user_agent
      t.string :request_id
      t.datetime :original_created_at, null: false
      t.timestamps
    end

    add_index :activity_log_archives, :user_id
    add_index :activity_log_archives, :original_created_at
    add_index :activity_log_archives, %i[category original_created_at]

    # Archive table for Tier 2 - User Event Logs
    create_table :user_event_archives do |t|
      t.bigint :user_id
      t.string :event_type, limit: 20
      t.string :path, limit: 500
      t.string :method, limit: 10
      t.string :controller, limit: 100
      t.string :action, limit: 50
      t.json :params
      t.integer :response_status, limit: 2
      t.integer :duration_ms
      t.string :ip_address, limit: 45
      t.text :user_agent
      t.string :session_id, limit: 100
      t.string :request_id, limit: 50
      t.datetime :original_created_at, null: false
      t.timestamps
    end

    add_index :user_event_archives, :user_id
    add_index :user_event_archives, :original_created_at
    add_index :user_event_archives, %i[event_type original_created_at]
  end
end
