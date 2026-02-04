# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_02_04_085600) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_log_archives", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "user_name", limit: 100
    t.string "action", limit: 50, null: false
    t.string "category", limit: 20
    t.string "subject_type"
    t.bigint "subject_id"
    t.json "details"
    t.json "record_changes"
    t.string "ip_address", limit: 45
    t.string "user_agent"
    t.string "request_id"
    t.datetime "original_created_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category", "original_created_at"], name: "idx_on_category_original_created_at_65caeb630b"
    t.index ["original_created_at"], name: "index_activity_log_archives_on_original_created_at"
    t.index ["user_id"], name: "index_activity_log_archives_on_user_id"
  end

  create_table "activity_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "action", limit: 50, null: false
    t.string "subject_type"
    t.bigint "subject_id"
    t.json "details"
    t.string "ip_address", limit: 45
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_name", limit: 100
    t.json "record_changes"
    t.string "category", limit: 20
    t.string "request_id"
    t.index ["action"], name: "index_activity_logs_on_action"
    t.index ["category", "created_at"], name: "index_activity_logs_on_category_and_created_at"
    t.index ["category"], name: "index_activity_logs_on_category"
    t.index ["subject_type", "subject_id", "created_at"], name: "index_activity_logs_on_subject_and_created_at"
    t.index ["subject_type", "subject_id"], name: "index_activity_logs_on_subject"
    t.index ["user_id", "created_at"], name: "index_activity_logs_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "contacts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "code", limit: 20, null: false, comment: "Auto-generated: KH2026-XXX"
    t.string "name", limit: 100, null: false, comment: "Tên KH (thường là tên Zalo)"
    t.string "phone", limit: 20, comment: "SĐT - Unique"
    t.string "email", limit: 100
    t.string "zalo_link", comment: "Link profile Zalo"
    t.bigint "service_type_id", null: false, comment: "Loại nhu cầu - FK to service_types"
    t.integer "status", default: 0, null: false, comment: "Enum: Trạng thái contact"
    t.bigint "team_id", comment: "Team được phân (từ loại nhu cầu)"
    t.bigint "assigned_user_id", comment: "Sale được gán"
    t.bigint "created_by_id", null: false, comment: "Người tạo (Tổng đài)"
    t.datetime "assigned_at", comment: "Thời điểm gán cho Sale"
    t.datetime "next_appointment", comment: "Lịch hẹn tiếp theo"
    t.text "notes", comment: "Ghi chú tổng quát"
    t.datetime "closed_at", comment: "Thời điểm chốt/đóng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "zalo_id"
    t.bigint "source_id"
    t.json "visible_to_user_ids"
    t.datetime "last_expanded_at"
    t.bigint "province_id"
    t.string "address"
    t.datetime "last_interaction_at"
    t.index ["assigned_user_id", "status"], name: "index_contacts_on_assignee_and_status"
    t.index ["assigned_user_id"], name: "index_contacts_on_assigned_user_id"
    t.index ["code"], name: "index_contacts_on_code", unique: true
    t.index ["created_by_id"], name: "index_contacts_on_created_by_id"
    t.index ["last_expanded_at"], name: "index_contacts_on_last_expanded_at"
    t.index ["last_interaction_at"], name: "index_contacts_on_last_interaction_at"
    t.index ["next_appointment"], name: "index_contacts_on_next_appointment"
    t.index ["phone"], name: "index_contacts_on_phone", unique: true
    t.index ["province_id"], name: "index_contacts_on_province_id"
    t.index ["service_type_id"], name: "index_contacts_on_service_type_id"
    t.index ["source_id"], name: "index_contacts_on_source_id"
    t.index ["status", "team_id"], name: "index_contacts_on_status_and_team"
    t.index ["status"], name: "index_contacts_on_status"
    t.index ["team_id", "created_at"], name: "index_contacts_on_team_and_created_at"
    t.index ["team_id"], name: "index_contacts_on_team_id"
    t.index ["zalo_id"], name: "index_contacts_on_zalo_id", unique: true
  end

  create_table "holidays", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_holidays_on_date", unique: true
  end

  create_table "interactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.bigint "user_id", null: false
    t.text "content", null: false
    t.integer "interaction_method", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "scheduled_at"
    t.index ["contact_id", "created_at"], name: "index_interactions_on_contact_id_and_created_at"
    t.index ["contact_id"], name: "index_interactions_on_contact_id"
    t.index ["user_id"], name: "index_interactions_on_user_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "body"
    t.string "icon"
    t.string "icon_color"
    t.string "category", default: "system", null: false
    t.string "notification_type"
    t.integer "priority", default: 0
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.string "action_url"
    t.string "action_text"
    t.json "metadata"
    t.boolean "read", default: false
    t.datetime "read_at"
    t.boolean "seen", default: false
    t.datetime "seen_at"
    t.boolean "push_sent", default: false
    t.datetime "push_sent_at"
    t.boolean "email_sent", default: false
    t.datetime "email_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_notifications_on_created_at"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id", "category", "created_at"], name: "idx_notifications_user_category"
    t.index ["user_id", "read", "created_at"], name: "idx_notifications_user_unread"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "permissions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code", null: false
    t.string "name"
    t.string "category"
    t.index ["code"], name: "index_permissions_on_code", unique: true
  end

  create_table "province_regions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "province_id", null: false
    t.bigint "region_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["province_id", "region_id"], name: "index_province_regions_on_province_id_and_region_id", unique: true
    t.index ["province_id"], name: "index_province_regions_on_province_id"
    t.index ["region_id"], name: "index_province_regions_on_region_id"
  end

  create_table "provinces", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "code", limit: 20, null: false
    t.integer "position", default: 0
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_provinces_on_active"
    t.index ["code"], name: "index_provinces_on_code", unique: true
    t.index ["name"], name: "index_provinces_on_name", unique: true
    t.index ["position"], name: "index_provinces_on_position"
  end

  create_table "push_subscriptions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "endpoint", null: false
    t.string "p256dh", null: false
    t.string "auth", null: false
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "endpoint"], name: "index_push_subscriptions_on_user_id_and_endpoint", unique: true
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
  end

  create_table "reassign_requests", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.bigint "from_user_id", null: false
    t.bigint "to_user_id"
    t.bigint "requested_by_id", null: false
    t.bigint "approved_by_id"
    t.integer "request_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.text "reason", null: false
    t.text "rejection_reason"
    t.datetime "decided_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved_by_id"], name: "index_reassign_requests_on_approved_by_id"
    t.index ["contact_id", "status"], name: "index_reassign_requests_on_contact_id_and_status"
    t.index ["contact_id"], name: "index_reassign_requests_on_contact_id"
    t.index ["from_user_id", "status"], name: "index_reassign_requests_on_from_user_id_and_status"
    t.index ["from_user_id"], name: "index_reassign_requests_on_from_user_id"
    t.index ["requested_by_id"], name: "index_reassign_requests_on_requested_by_id"
    t.index ["to_user_id"], name: "index_reassign_requests_on_to_user_id"
  end

  create_table "regions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "code", limit: 20, null: false
    t.text "description"
    t.integer "position", default: 0
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_regions_on_active"
    t.index ["code"], name: "index_regions_on_code", unique: true
    t.index ["name"], name: "index_regions_on_name", unique: true
    t.index ["position"], name: "index_regions_on_position"
  end

  create_table "role_permissions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "permission_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["permission_id"], name: "index_role_permissions_on_permission_id"
    t.index ["role_id", "permission_id"], name: "index_role_permissions_on_role_id_and_permission_id", unique: true
    t.index ["role_id"], name: "index_role_permissions_on_role_id"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "is_system", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "dashboard_type", default: 0, null: false
    t.string "code"
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "saturday_schedule_users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "saturday_schedule_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["saturday_schedule_id", "user_id"], name: "index_saturday_schedule_users_on_schedule_and_user", unique: true
    t.index ["saturday_schedule_id"], name: "index_saturday_schedule_users_on_saturday_schedule_id"
    t.index ["user_id"], name: "index_saturday_schedule_users_on_user_id"
  end

  create_table "saturday_schedules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "date", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_saturday_schedules_on_date", unique: true
  end

  create_table "service_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "description"
    t.bigint "team_id", comment: "Default team for Smart Routing"
    t.boolean "active", default: true, null: false
    t.integer "position", default: 0, null: false, comment: "For ordering in dropdowns"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_service_types_on_active"
    t.index ["name"], name: "index_service_types_on_name", unique: true
    t.index ["team_id"], name: "index_service_types_on_team_id"
  end

  create_table "settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "solid_cable_messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.binary "channel", limit: 1024, null: false
    t.binary "payload", size: :long, null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.binary "key", limit: 1024, null: false
    t.binary "value", size: :long, null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "sources", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sources_on_name", unique: true
  end

  create_table "team_members", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_members_on_team_id"
    t.index ["user_id", "team_id"], name: "index_team_members_on_user_id_and_team_id", unique: true
    t.index ["user_id"], name: "index_team_members_on_user_id"
  end

  create_table "teams", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.text "description"
    t.string "region", limit: 50
    t.bigint "manager_id", comment: "FK to users.id - Team manager"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id"], name: "index_teams_on_manager_id"
    t.index ["name"], name: "index_teams_on_name", unique: true
    t.index ["region"], name: "index_teams_on_region"
  end

  create_table "user_event_archives", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "event_type", limit: 20
    t.string "path", limit: 500
    t.string "method", limit: 10
    t.string "controller", limit: 100
    t.string "action", limit: 50
    t.json "params"
    t.integer "response_status", limit: 2
    t.integer "duration_ms"
    t.string "ip_address", limit: 45
    t.text "user_agent"
    t.string "session_id", limit: 100
    t.string "request_id", limit: 50
    t.datetime "original_created_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type", "original_created_at"], name: "idx_on_event_type_original_created_at_c9fec24ac9"
    t.index ["original_created_at"], name: "index_user_event_archives_on_original_created_at"
    t.index ["user_id"], name: "index_user_event_archives_on_user_id"
  end

  create_table "user_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "event_type", limit: 20
    t.string "path", limit: 500
    t.string "method", limit: 10
    t.string "controller", limit: 100
    t.string "action", limit: 50
    t.json "params"
    t.integer "response_status", limit: 2
    t.integer "duration_ms"
    t.string "ip_address", limit: 45
    t.text "user_agent"
    t.string "session_id", limit: 100
    t.string "request_id", limit: 50
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_user_events_on_created_at"
    t.index ["event_type", "created_at"], name: "index_user_events_on_event_type_and_created_at"
    t.index ["request_id"], name: "index_user_events_on_request_id"
    t.index ["user_id", "created_at"], name: "index_user_events_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_user_events_on_user_id"
  end

  create_table "user_permissions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "permission_id", null: false
    t.boolean "granted", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id"
    t.index ["created_by_id"], name: "index_user_permissions_on_created_by_id"
    t.index ["permission_id"], name: "index_user_permissions_on_permission_id"
    t.index ["user_id", "permission_id"], name: "index_user_permissions_on_user_id_and_permission_id", unique: true
    t.index ["user_id"], name: "index_user_permissions_on_user_id"
  end

  create_table "user_roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "user_service_type_limits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "service_type_id", null: false
    t.integer "max_pick_per_day", default: 10, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_type_id"], name: "index_user_service_type_limits_on_service_type_id"
    t.index ["user_id", "service_type_id"], name: "idx_user_service_type_limits_unique", unique: true
    t.index ["user_id"], name: "index_user_service_type_limits_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.string "phone", default: ""
    t.integer "status", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", limit: 50
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.bigint "region_id"
    t.text "address"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["region_id"], name: "index_users_on_region_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "contacts", "provinces"
  add_foreign_key "contacts", "service_types"
  add_foreign_key "contacts", "sources"
  add_foreign_key "contacts", "teams", on_delete: :nullify
  add_foreign_key "contacts", "users", column: "assigned_user_id", on_delete: :nullify
  add_foreign_key "contacts", "users", column: "created_by_id"
  add_foreign_key "interactions", "contacts"
  add_foreign_key "interactions", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "province_regions", "provinces"
  add_foreign_key "province_regions", "regions"
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "reassign_requests", "contacts"
  add_foreign_key "reassign_requests", "users", column: "approved_by_id"
  add_foreign_key "reassign_requests", "users", column: "from_user_id"
  add_foreign_key "reassign_requests", "users", column: "requested_by_id"
  add_foreign_key "reassign_requests", "users", column: "to_user_id"
  add_foreign_key "role_permissions", "permissions"
  add_foreign_key "role_permissions", "roles"
  add_foreign_key "saturday_schedule_users", "saturday_schedules"
  add_foreign_key "saturday_schedule_users", "users"
  add_foreign_key "service_types", "teams", on_delete: :nullify
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "team_members", "teams"
  add_foreign_key "team_members", "users"
  add_foreign_key "teams", "users", column: "manager_id", on_delete: :nullify
  add_foreign_key "user_events", "users"
  add_foreign_key "user_permissions", "permissions"
  add_foreign_key "user_permissions", "users"
  add_foreign_key "user_permissions", "users", column: "created_by_id"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "user_service_type_limits", "service_types"
  add_foreign_key "user_service_type_limits", "users"
end
