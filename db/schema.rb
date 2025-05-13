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

ActiveRecord::Schema[8.0].define(version: 2025_05_13_091954) do
  create_schema "digital_assets"

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "assets", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "file_url"
    t.decimal "price"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "user_assets_idx"
  end

  create_table "purchases", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "asset_id", null: false
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "asset_purchases_idx"
    t.index ["user_id"], name: "user_purchases_idx"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "encrypted_password"
    t.integer "role"
    t.decimal "total_earnings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "email_unique_idx", unique: true
  end

  add_foreign_key "assets", "users"
  add_foreign_key "purchases", "assets"
  add_foreign_key "purchases", "users"
end
