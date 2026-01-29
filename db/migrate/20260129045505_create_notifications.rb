# frozen_string_literal: true

# TASK-057: Create notifications table for in-app notification system
# Designed for extensibility: multi-channel delivery, polymorphic references
class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      # === Core Fields ===
      t.references :user, null: false, foreign_key: true, index: true

      # === Content ===
      t.string :title, null: false
      t.text :body
      t.string :icon                    # Font Awesome icon class (fa-user-plus)
      t.string :icon_color              # CSS color (blue, green, red)

      # === Categorization ===
      t.string :category, null: false, default: 'system'
      t.string :notification_type       # contact_created, contact_picked, etc.
      t.integer :priority, default: 0   # 0=normal, 1=high, 2=urgent

      # === Polymorphic Reference ===
      t.references :notifiable, polymorphic: true, index: true

      # === Action ===
      t.string :action_url              # URL when clicking notification
      t.string :action_text             # Button text (optional)

      # === Metadata (Extensible) ===
      t.json :metadata

      # === Status Tracking ===
      t.boolean :read, default: false
      t.datetime :read_at
      t.boolean :seen, default: false   # Seen in dropdown (not clicked)
      t.datetime :seen_at

      # === Delivery Status (Future: Web Push, Email) ===
      t.boolean :push_sent, default: false
      t.datetime :push_sent_at
      t.boolean :email_sent, default: false
      t.datetime :email_sent_at

      t.timestamps
    end

    # === Indexes for Performance ===
    add_index :notifications, %i[user_id read created_at],
              name: 'idx_notifications_user_unread'
    add_index :notifications, %i[user_id category created_at],
              name: 'idx_notifications_user_category'
    add_index :notifications, :created_at
  end
end
