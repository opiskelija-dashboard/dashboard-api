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

ActiveRecord::Schema.define(version: 20170821085626) do

  create_table "awarded_badges", force: :cascade do |t|
    t.integer  "badge_definition_id"
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "badge_criteria", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "code"
    t.integer  "created_by"
    t.integer  "modified_by"
    t.boolean  "bugs"
    t.boolean  "course_points_only"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "badge_criteria_definitions", id: false, force: :cascade do |t|
    t.integer "badge_criterium_id",  null: false
    t.integer "badge_definition_id", null: false
    t.index ["badge_criterium_id", "badge_definition_id"], name: "index_for_badge_crit_to_badge_def"
    t.index ["badge_definition_id", "badge_criterium_id"], name: "index_for_badge_def_to_badge_crit"
  end

  create_table "badge_definitions", force: :cascade do |t|
    t.string   "name"
    t.string   "iconref"
    t.string   "flavor_text"
    t.integer  "made_by"
    t.boolean  "active"
    t.boolean  "course_specific"
    t.boolean  "global"
    t.integer  "course_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

end
