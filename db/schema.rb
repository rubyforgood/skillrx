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

ActiveRecord::Schema[8.1].define(version: 2026_02_03_100006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "beacon_providers", force: :cascade do |t|
    t.bigint "beacon_id", null: false
    t.datetime "created_at", null: false
    t.bigint "provider_id", null: false
    t.datetime "updated_at", null: false
    t.index ["beacon_id", "provider_id"], name: "index_beacon_providers_on_beacon_id_and_provider_id", unique: true
    t.index ["beacon_id"], name: "index_beacon_providers_on_beacon_id"
    t.index ["provider_id"], name: "index_beacon_providers_on_provider_id"
  end

  create_table "beacon_topics", force: :cascade do |t|
    t.bigint "beacon_id", null: false
    t.datetime "created_at", null: false
    t.bigint "topic_id", null: false
    t.datetime "updated_at", null: false
    t.index ["beacon_id", "topic_id"], name: "index_beacon_topics_on_beacon_id_and_topic_id", unique: true
    t.index ["beacon_id"], name: "index_beacon_topics_on_beacon_id"
    t.index ["topic_id"], name: "index_beacon_topics_on_topic_id"
  end

  create_table "beacons", force: :cascade do |t|
    t.string "api_key_digest", null: false
    t.string "api_key_prefix", null: false
    t.datetime "created_at", null: false
    t.bigint "language_id", null: false
    t.string "manifest_checksum"
    t.jsonb "manifest_data"
    t.integer "manifest_version", default: 0, null: false
    t.string "name", null: false
    t.bigint "region_id", null: false
    t.datetime "revoked_at"
    t.datetime "updated_at", null: false
    t.index ["api_key_digest"], name: "index_beacons_on_api_key_digest", unique: true
    t.index ["language_id"], name: "index_beacons_on_language_id"
    t.index ["region_id"], name: "index_beacons_on_region_id"
  end

  create_table "branches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "provider_id"
    t.bigint "region_id"
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_branches_on_provider_id"
    t.index ["region_id"], name: "index_branches_on_region_id"
  end

  create_table "contributors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "provider_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["provider_id"], name: "index_contributors_on_provider_id"
    t.index ["user_id"], name: "index_contributors_on_user_id"
  end

  create_table "import_errors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error_message"
    t.string "error_type", null: false
    t.string "file_name"
    t.bigint "import_report_id", null: false
    t.json "metadata"
    t.integer "topic_id"
    t.datetime "updated_at", null: false
    t.index ["error_type"], name: "index_import_errors_on_error_type"
    t.index ["file_name"], name: "index_import_errors_on_file_name"
    t.index ["import_report_id"], name: "index_import_errors_on_import_report_id"
  end

  create_table "import_reports", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.json "error_details"
    t.string "import_type", null: false
    t.datetime "started_at"
    t.string "status", default: "pending"
    t.json "summary_stats"
    t.json "unmatched_files"
    t.datetime "updated_at", null: false
    t.index ["import_type"], name: "index_import_reports_on_import_type"
  end

  create_table "languages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "providers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "file_name_prefix"
    t.string "name"
    t.integer "old_id"
    t.string "provider_type"
    t.datetime "updated_at", null: false
    t.index ["old_id"], name: "index_providers_on_old_id", unique: true
  end

  create_table "regions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tag_cognates", force: :cascade do |t|
    t.bigint "cognate_id"
    t.datetime "created_at", null: false
    t.bigint "tag_id"
    t.datetime "updated_at", null: false
    t.index ["cognate_id"], name: "index_tag_cognates_on_cognate_id"
    t.index ["tag_id", "cognate_id"], name: "index_tag_cognates_on_tag_id_and_cognate_id", unique: true
    t.index ["tag_id"], name: "index_tag_cognates_on_tag_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.string "context", limit: 128
    t.datetime "created_at", precision: nil
    t.bigint "tag_id"
    t.bigint "taggable_id"
    t.string "taggable_type"
    t.bigint "tagger_id"
    t.string "tagger_type"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
    t.index ["tagger_type", "tagger_id"], name: "index_taggings_on_tagger_type_and_tagger_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "taggings_count", default: 0
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "topics", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "document_prefix"
    t.bigint "language_id"
    t.integer "old_id"
    t.bigint "provider_id"
    t.datetime "published_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.boolean "shadow_copy", default: false, null: false
    t.integer "state", default: 0, null: false
    t.string "title", null: false
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_topics_on_language_id"
    t.index ["old_id"], name: "index_topics_on_old_id", unique: true
    t.index ["provider_id"], name: "index_topics_on_provider_id"
    t.index ["published_at"], name: "index_topics_on_published_at"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "is_admin", default: false, null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "beacon_providers", "beacons"
  add_foreign_key "beacon_providers", "providers"
  add_foreign_key "beacon_topics", "beacons"
  add_foreign_key "beacon_topics", "topics"
  add_foreign_key "beacons", "languages"
  add_foreign_key "beacons", "regions"
  add_foreign_key "import_errors", "import_reports"
  add_foreign_key "sessions", "users"
  add_foreign_key "tag_cognates", "tags"
  add_foreign_key "tag_cognates", "tags", column: "cognate_id"
  add_foreign_key "taggings", "tags"
end
