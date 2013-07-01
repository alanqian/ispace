# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20130624034837) do

  create_table "bays", force: true do |t|
    t.string   "name",                                   null: false
    t.decimal  "back_height",    precision: 6, scale: 1, null: false
    t.decimal  "back_width",     precision: 7, scale: 1, null: false
    t.decimal  "back_thick",     precision: 6, scale: 1, null: false
    t.string   "back_color",                             null: false
    t.decimal  "notch_spacing",  precision: 6, scale: 1
    t.decimal  "notch_1st",      precision: 6, scale: 1
    t.decimal  "base_height",    precision: 6, scale: 1, null: false
    t.decimal  "base_width",     precision: 6, scale: 1, null: false
    t.decimal  "base_depth",     precision: 6, scale: 1, null: false
    t.string   "base_color",                             null: false
    t.decimal  "takeoff_height", precision: 6, scale: 1
    t.integer  "elem_type"
    t.integer  "elem_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "freezer_chests", force: true do |t|
    t.integer  "bay_id"
    t.integer  "level"
    t.string   "name"
    t.decimal  "height",        precision: 6, scale: 1, null: false
    t.decimal  "depth",         precision: 6, scale: 1, null: false
    t.decimal  "wall_thick",    precision: 6, scale: 1, null: false
    t.decimal  "inside_height", precision: 6, scale: 1, null: false
    t.decimal  "merch_height",  precision: 6, scale: 1, null: false
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_shelves", force: true do |t|
    t.integer  "bay_id"
    t.integer  "level"
    t.string   "name"
    t.decimal  "height",       precision: 6, scale: 1, null: false
    t.decimal  "width",        precision: 6, scale: 1, null: false
    t.decimal  "depth",        precision: 6, scale: 1, null: false
    t.decimal  "thick",        precision: 6, scale: 1, null: false
    t.decimal  "slope",        precision: 4, scale: 1, null: false
    t.decimal  "riser",        precision: 6, scale: 1, null: false
    t.integer  "notch_num"
    t.decimal  "from_base",    precision: 6, scale: 1, null: false
    t.string   "color"
    t.decimal  "from_back",    precision: 6, scale: 1, null: false
    t.decimal  "finger_space", precision: 6, scale: 1, null: false
    t.decimal  "x_position",   precision: 6, scale: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "peg_boards", force: true do |t|
    t.integer  "bay_id"
    t.integer  "level"
    t.string   "name"
    t.decimal  "height",     precision: 6, scale: 1, null: false
    t.decimal  "depth",      precision: 6, scale: 1, null: false
    t.decimal  "vert_space", precision: 6, scale: 1, null: false
    t.decimal  "horz_space", precision: 6, scale: 1, null: false
    t.decimal  "vert_start", precision: 6, scale: 1, null: false
    t.decimal  "horz_start", precision: 6, scale: 1, null: false
    t.integer  "notch_num"
    t.decimal  "from_base",  precision: 6, scale: 1, null: false
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rear_support_bars", force: true do |t|
    t.integer  "bay_id"
    t.integer  "level"
    t.string   "name"
    t.decimal  "height",      precision: 6, scale: 1, null: false
    t.decimal  "bar_depth",   precision: 6, scale: 1, null: false
    t.decimal  "bar_thick",   precision: 6, scale: 1, null: false
    t.decimal  "from_back",   precision: 6, scale: 1, null: false
    t.decimal  "hook_length", precision: 6, scale: 1, null: false
    t.integer  "notch_num"
    t.decimal  "from_base",   precision: 6, scale: 1, null: false
    t.string   "color"
    t.decimal  "bar_slope",   precision: 4, scale: 1, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
