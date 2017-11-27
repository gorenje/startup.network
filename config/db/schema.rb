# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170530104757) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "entities", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "url"
    t.string "image_url"
    t.hstore "data"
    t.string "classname"
    t.integer "location_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_entities_on_location_id"
    t.index ["url"], name: "index_entities_on_url"
  end

  create_table "exit_strategies", id: :serial, force: :cascade do |t|
    t.string "kind"
    t.text "description"
    t.integer "startup_id"
  end

  create_table "founding_structure", id: :serial, force: :cascade do |t|
    t.string "kind"
    t.text "description"
  end

  create_table "investments", id: :serial, force: :cascade do |t|
    t.decimal "valuation", precision: 10, scale: 2
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency"
    t.string "kind"
    t.string "stake_percent"
    t.date "when"
    t.integer "entity_id"
    t.integer "startup_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_investments_on_entity_id"
    t.index ["startup_id"], name: "index_investments_on_startup_id"
  end

  create_table "key_employees", id: :serial, force: :cascade do |t|
    t.string "role"
    t.hstore "data"
    t.integer "entity_id"
    t.integer "startup_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_key_employees_on_entity_id"
    t.index ["startup_id"], name: "index_key_employees_on_startup_id"
  end

  create_table "keywords", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
  end

  create_table "keywords_startups", id: :serial, force: :cascade do |t|
    t.integer "keyword_id"
    t.integer "startup_id"
    t.index ["keyword_id"], name: "index_keywords_startups_on_keyword_id"
    t.index ["startup_id"], name: "index_keywords_startups_on_startup_id"
  end

  create_table "locations", id: :serial, force: :cascade do |t|
    t.string "street_one"
    t.string "street_two"
    t.string "city"
    t.string "country"
    t.string "postcode"
    t.string "email"
    t.string "phone"
    t.string "mobile"
    t.hstore "data"
    t.string "kind"
    t.index ["email", "phone"], name: "index_locations_on_email_and_phone"
  end

  create_table "offers", id: :serial, force: :cascade do |t|
    t.string "amount"
    t.string "classname"
    t.integer "entity_id"
    t.integer "investment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.index ["entity_id"], name: "index_offers_on_entity_id"
    t.index ["investment_id"], name: "index_offers_on_investment_id"
    t.index ["user_id"], name: "index_offers_on_user_id"
  end

  create_table "startups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "logo_url"
    t.date "founded"
    t.date "exited"
    t.text "description"
    t.string "tagline"
    t.string "industry"
    t.string "sector"
    t.hstore "data"
    t.decimal "valuation_current", precision: 10, scale: 2
    t.decimal "success_chances"
    t.integer "founding_structure_id"
    t.integer "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["founding_structure_id"], name: "index_startups_on_founding_structure_id"
    t.index ["url"], name: "index_startups_on_url"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.boolean "email_verified"
    t.text "credentials"
    t.string "salt"
    t.string "confirm_token"
    t.boolean "has_confirmed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
