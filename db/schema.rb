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

ActiveRecord::Schema.define(version: 20130709135933) do

  create_table "bays", force: true do |t|
    t.string   "name",                                    null: false
    t.decimal  "back_height",    precision: 6,  scale: 1, null: false
    t.decimal  "back_width",     precision: 7,  scale: 1, null: false
    t.decimal  "back_thick",     precision: 6,  scale: 1, null: false
    t.string   "back_color",                              null: false
    t.decimal  "notch_spacing",  precision: 6,  scale: 1
    t.decimal  "notch_1st",      precision: 6,  scale: 1
    t.decimal  "base_height",    precision: 6,  scale: 1, null: false
    t.decimal  "base_width",     precision: 6,  scale: 1, null: false
    t.decimal  "base_depth",     precision: 6,  scale: 1, null: false
    t.string   "base_color",                              null: false
    t.decimal  "takeoff_height", precision: 6,  scale: 1
    t.integer  "elem_type"
    t.integer  "elem_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "linear",         precision: 10, scale: 0
    t.decimal  "area",           precision: 10, scale: 0
    t.decimal  "cube",           precision: 10, scale: 0
  end

  create_table "categories", force: true do |t|
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fixture_items", force: true do |t|
    t.integer  "fixture_id"
    t.integer  "bay_id"
    t.integer  "num_bays"
    t.integer  "item_index"
    t.boolean  "continuous"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fixture_items", ["bay_id"], name: "index_fixture_items_on_bay_id", using: :btree
  add_index "fixture_items", ["fixture_id"], name: "index_fixture_items_on_fixture_id", using: :btree

  create_table "fixtures", force: true do |t|
    t.string   "name"
    t.integer  "store_id"
    t.integer  "user_id"
    t.string   "category_id"
    t.boolean  "flow_l2r"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fixtures", ["category_id"], name: "index_fixtures_on_category_id", using: :btree
  add_index "fixtures", ["name"], name: "index_fixtures_on_name", using: :btree
  add_index "fixtures", ["user_id"], name: "index_fixtures_on_user_id", using: :btree

  create_table "freezer_chests", force: true do |t|
    t.integer  "bay_id"
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

  add_index "freezer_chests", ["bay_id"], name: "index_freezer_chests_on_bay_id", using: :btree

  create_table "open_shelves", force: true do |t|
    t.integer  "bay_id"
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

  add_index "open_shelves", ["bay_id"], name: "index_open_shelves_on_bay_id", using: :btree

  create_table "peg_boards", force: true do |t|
    t.integer  "bay_id"
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

  add_index "peg_boards", ["bay_id"], name: "index_peg_boards_on_bay_id", using: :btree

  create_table "rear_support_bars", force: true do |t|
    t.integer  "bay_id"
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

  add_index "rear_support_bars", ["bay_id"], name: "index_rear_support_bars_on_bay_id", using: :btree

  create_table "regions", force: true do |t|
    t.string   "name",       null: false
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "regions", ["name"], name: "index_regions_on_name", using: :btree

  create_table "stores", force: true do |t|
    t.string   "region_id",  null: false
    t.string   "name"
    t.string   "desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stores", ["name"], name: "index_stores_on_name", using: :btree
  add_index "stores", ["region_id"], name: "index_stores_on_region_id", using: :btree

end
