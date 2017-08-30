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

ActiveRecord::Schema.define(version: 20170830094126) do

  create_table "badge_codes", force: :cascade do |t|
    t.string   "name",                          null: false
    t.string   "description"
    t.string   "code",                          null: false
    t.integer  "created_by"
    t.integer  "modified_by"
    t.boolean  "active",        default: false
    t.boolean  "course_points", default: true
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.boolean  "user_points"
    t.boolean  "exercises"
  end

  create_table "badge_codes_defs", id: false, force: :cascade do |t|
    t.integer "badge_code_id", null: false
    t.integer "badge_def_id",  null: false
    t.index ["badge_code_id", "badge_def_id"], name: "index_for_badge_code_to_badge_def"
    t.index ["badge_def_id", "badge_code_id"], name: "index_for_badge_def_to_badge_code"
  end

  create_table "badge_defs", force: :cascade do |t|
    t.string   "name",                        null: false
    t.string   "iconref"
    t.string   "flavor_text"
    t.integer  "made_by"
    t.boolean  "active",      default: false
    t.integer  "course_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "badges", force: :cascade do |t|
    t.integer  "badge_def_id", null: false
    t.integer  "user_id",      null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

end
