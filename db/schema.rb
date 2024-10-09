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

ActiveRecord::Schema[7.1].define(version: 2024_10_09_215145) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "car_models", force: :cascade do |t|
    t.string "car_model"
    t.string "car_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "car_numbers", force: :cascade do |t|
    t.integer "number"
    t.bigint "race_day_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["race_day_id"], name: "index_car_numbers_on_race_day_id"
  end

  create_table "championships", force: :cascade do |t|
    t.string "car_id"
    t.integer "race_number"
    t.string "car_model"
    t.string "driver_first_name"
    t.string "driver_last_name"
    t.string "best_lap"
    t.string "total_time"
    t.integer "lap_count"
    t.date "session_date"
    t.time "session_time"
    t.string "session_type"
    t.string "track_name"
    t.text "laps"
    t.string "penalty_reason", default: [], array: true
    t.string "penalty_type", default: [], array: true
    t.integer "penalty_value", default: [], array: true
    t.integer "penalty_violation_in_lap", default: [], array: true
    t.integer "penalty_cleared_in_lap", default: [], array: true
    t.string "post_race_penalty_reason"
    t.string "post_race_penalty_type"
    t.integer "post_race_penalty_value"
    t.integer "post_race_penalty_violation_in_lap"
    t.integer "post_race_penalty_cleared_in_lap"
    t.integer "points"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.integer "penalty_points", default: [], array: true
    t.string "season"
  end

  create_table "drivers", force: :cascade do |t|
    t.string "car_id"
    t.integer "race_number"
    t.string "car_model"
    t.string "driver_first_name"
    t.string "driver_last_name"
    t.string "best_lap"
    t.string "total_time"
    t.integer "lap_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "session_date"
    t.time "session_time"
    t.string "session_type"
    t.string "track_name"
    t.text "laps"
    t.string "penalty_reason"
    t.string "penalty_type"
    t.integer "penalty_value"
    t.integer "penalty_violation_in_lap"
    t.integer "penalty_cleared_in_lap"
    t.string "post_race_penalty_reason"
    t.string "post_race_penalty_type"
    t.integer "post_race_penalty_value"
    t.integer "post_race_penalty_violation_in_lap"
    t.integer "post_race_penalty_cleared_in_lap"
    t.integer "points"
  end

  create_table "pilot_registrations", force: :cascade do |t|
    t.string "pilot_name"
    t.bigint "race_day_id", null: false
    t.bigint "car_number_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_number_id"], name: "index_pilot_registrations_on_car_number_id"
    t.index ["race_day_id"], name: "index_pilot_registrations_on_race_day_id"
  end

  create_table "pilots", force: :cascade do |t|
    t.string "name"
    t.string "instagram"
    t.string "twitch"
    t.string "youtube"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.string "categoria"
  end

  create_table "processed_files", force: :cascade do |t|
    t.string "file_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "race_days", force: :cascade do |t|
    t.date "date"
    t.integer "max_pilots"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "track_id"
    t.index ["track_id"], name: "index_race_days_on_track_id"
  end

  create_table "sponsors", force: :cascade do |t|
    t.string "nome"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tracks", force: :cascade do |t|
    t.string "track_id"
    t.string "track_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name"
    t.string "uid"
    t.string "avatar_url"
    t.string "provider"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.string "number"
    t.boolean "ucrdriver", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "car_numbers", "race_days"
  add_foreign_key "pilot_registrations", "car_numbers"
  add_foreign_key "pilot_registrations", "race_days"
  add_foreign_key "race_days", "tracks"
end
