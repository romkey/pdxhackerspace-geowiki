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

ActiveRecord::Schema[8.1].define(version: 2024_12_14_000015) do
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

  create_table "journal_entries", force: :cascade do |t|
    t.string "action", null: false
    t.json "changes_made"
    t.datetime "created_at", null: false
    t.text "details"
    t.bigint "journable_id", null: false
    t.string "journable_type", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["action"], name: "index_journal_entries_on_action"
    t.index ["created_at"], name: "index_journal_entries_on_created_at"
    t.index ["journable_type", "journable_id"], name: "index_journal_entries_on_journable"
    t.index ["user_id"], name: "index_journal_entries_on_user_id"
  end

  create_table "map_maintainers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "map_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["map_id", "user_id"], name: "index_map_maintainers_on_map_id_and_user_id", unique: true
    t.index ["map_id"], name: "index_map_maintainers_on_map_id"
    t.index ["user_id"], name: "index_map_maintainers_on_user_id"
  end

  create_table "maps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_default", default: false, null: false
    t.string "name", null: false
    t.bigint "parent_id"
    t.string "slack_channel"
    t.datetime "updated_at", null: false
    t.index ["is_default"], name: "index_maps_on_is_default", unique: true, where: "(is_default = true)"
    t.index ["name"], name: "index_maps_on_name"
    t.index ["parent_id"], name: "index_maps_on_parent_id"
  end

  create_table "resource_external_locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "label"
    t.decimal "latitude", precision: 10, scale: 7, null: false
    t.decimal "longitude", precision: 10, scale: 7, null: false
    t.bigint "resource_id", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["resource_id", "latitude", "longitude"], name: "index_resource_external_locations_on_resource_coords"
    t.index ["resource_id"], name: "index_resource_external_locations_on_resource_id"
  end

  create_table "resource_locations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "map_id", null: false
    t.bigint "resource_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "x", precision: 6, scale: 3, null: false
    t.decimal "y", precision: 6, scale: 3, null: false
    t.index ["map_id"], name: "index_resource_locations_on_map_id"
    t.index ["resource_id", "map_id"], name: "index_resource_locations_on_resource_id_and_map_id"
    t.index ["resource_id"], name: "index_resource_locations_on_resource_id"
  end

  create_table "resource_urls", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "label"
    t.bigint "resource_id", null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["resource_id", "url"], name: "index_resource_urls_on_resource_id_and_url", unique: true
    t.index ["resource_id"], name: "index_resource_urls_on_resource_id"
  end

  create_table "resources", force: :cascade do |t|
    t.boolean "admin_only", default: false, null: false
    t.datetime "created_at", null: false
    t.boolean "internal", default: true, null: false
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.string "name", null: false
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.integer "view_count", default: 0, null: false
    t.index ["internal"], name: "index_resources_on_internal"
    t.index ["name"], name: "index_resources_on_name"
    t.index ["parent_id"], name: "index_resources_on_parent_id"
    t.index ["view_count"], name: "index_resources_on_view_count"
  end

  create_table "site_configs", force: :cascade do |t|
    t.text "address"
    t.datetime "created_at", null: false
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.string "organization_name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.boolean "is_admin", default: false, null: false
    t.string "name"
    t.string "password_digest"
    t.string "provider"
    t.string "uid"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "journal_entries", "users"
  add_foreign_key "map_maintainers", "maps"
  add_foreign_key "map_maintainers", "users"
  add_foreign_key "maps", "maps", column: "parent_id"
  add_foreign_key "resource_external_locations", "resources"
  add_foreign_key "resource_locations", "maps"
  add_foreign_key "resource_locations", "resources"
  add_foreign_key "resource_urls", "resources"
  add_foreign_key "resources", "resources", column: "parent_id"
end
