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

ActiveRecord::Schema.define(version: 2020_05_29_143949) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_query_logs", force: :cascade do |t|
    t.string "controller"
    t.string "action"
    t.string "response"
    t.integer "status"
    t.string "params"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "country_name"
    t.boolean "all_countries"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "scraper_ban_requests", force: :cascade do |t|
    t.bigint "banner_id"
    t.bigint "bannee_id"
    t.bigint "scraper_request_id", null: false
    t.text "ban_description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "published_date"
    t.string "status"
    t.index ["bannee_id"], name: "index_scraper_ban_requests_on_bannee_id"
    t.index ["banner_id"], name: "index_scraper_ban_requests_on_banner_id"
    t.index ["scraper_request_id"], name: "index_scraper_ban_requests_on_scraper_request_id"
  end

  create_table "scraper_requests", force: :cascade do |t|
    t.date "date"
    t.string "source"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "scrapper_ban_requests", force: :cascade do |t|
    t.bigint "banner_id"
    t.bigint "bannee_id"
    t.string "source"
    t.text "ban_request_description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "scrapper_request_id", null: false
    t.index ["bannee_id"], name: "index_scrapper_ban_requests_on_bannee_id"
    t.index ["banner_id"], name: "index_scrapper_ban_requests_on_banner_id"
    t.index ["scrapper_request_id"], name: "index_scrapper_ban_requests_on_scrapper_request_id"
  end

  create_table "scrapper_requests", force: :cascade do |t|
    t.date "scrape_date"
    t.string "source"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "firebase_uuid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "scraper_ban_requests", "scraper_requests"
  add_foreign_key "scrapper_ban_requests", "scrapper_requests"
end
