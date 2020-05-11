# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_03_21_151438) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ban_requests", force: :cascade do |t|
    t.string "ban_type"
    t.string "ban_description"
    t.string "ban_url"
    t.bigint "banner_id"
    t.bigint "bannee_id"
    t.bigint "contributor_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bannee_id"], name: "index_ban_requests_on_bannee_id"
    t.index ["banner_id"], name: "index_ban_requests_on_banner_id"
    t.index ["contributor_id"], name: "index_ban_requests_on_contributor_id"
  end

  create_table "bans", force: :cascade do |t|
    t.string "ban_type"
    t.string "ban_description"
    t.bigint "banner_id"
    t.bigint "bannee_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "ban_url"
    t.index ["bannee_id"], name: "index_bans_on_bannee_id"
    t.index ["banner_id"], name: "index_bans_on_banner_id"
  end

  create_table "contributors", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "code"
    t.integer "level"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "country_name"
  end

end
