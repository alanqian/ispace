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

ActiveRecord::Schema.define(version: 20130909155648) do

  create_table "bays", force: true do |t|
    t.string   "name",                                   null: false
    t.decimal  "back_height",   precision: 6,  scale: 1, null: false
    t.decimal  "back_width",    precision: 7,  scale: 1, null: false
    t.decimal  "back_thick",    precision: 6,  scale: 1, null: false
    t.string   "back_color",                             null: false
    t.decimal  "notch_spacing", precision: 6,  scale: 1
    t.decimal  "notch_1st",     precision: 6,  scale: 1
    t.decimal  "base_height",   precision: 6,  scale: 1, null: false
    t.decimal  "base_width",    precision: 6,  scale: 1, null: false
    t.decimal  "base_depth",    precision: 6,  scale: 1, null: false
    t.string   "base_color",                             null: false
    t.integer  "elem_type"
    t.integer  "elem_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "linear",        precision: 10, scale: 0
    t.decimal  "area",          precision: 10, scale: 0
    t.decimal  "cube",          precision: 10, scale: 0
  end

  create_table "brands", force: true do |t|
    t.string   "name"
    t.string   "category_id"
    t.string   "color"
    t.integer  "import_id",    default: -1
    t.datetime "discard_from"
    t.integer  "discard_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "brands", ["discard_from"], name: "index_brands_on_discard_from", using: :btree
  add_index "brands", ["import_id"], name: "index_brands_on_import_id", using: :btree
  add_index "brands", ["name", "category_id"], name: "index_brands_on_name_and_category_id", unique: true, using: :btree

  create_table "categories", id: false, force: true do |t|
    t.string   "name",                  null: false
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",       limit: 32, null: false
    t.string   "parent_id",  limit: 32
  end

  add_index "categories", ["code"], name: "index_categories_on_code", unique: true, using: :btree
  add_index "categories", ["name"], name: "index_categories_on_name", unique: true, using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree

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
    t.integer  "user_id"
    t.string   "category_id"
    t.boolean  "flow_l2r"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",        limit: 48, default: "", null: false
  end

  add_index "fixtures", ["category_id"], name: "index_fixtures_on_category_id", using: :btree
  add_index "fixtures", ["code"], name: "index_fixtures_on_code", using: :btree
  add_index "fixtures", ["name"], name: "index_fixtures_on_name", using: :btree
  add_index "fixtures", ["user_id"], name: "index_fixtures_on_user_id", using: :btree

  create_table "freezer_chests", force: true do |t|
    t.integer  "bay_id"
    t.string   "name"
    t.decimal  "height",        precision: 6, scale: 1,             null: false
    t.decimal  "depth",         precision: 6, scale: 1,             null: false
    t.decimal  "wall_thick",    precision: 6, scale: 1,             null: false
    t.decimal  "inside_height", precision: 6, scale: 1,             null: false
    t.decimal  "merch_height",  precision: 6, scale: 1,             null: false
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",                                 default: 0, null: false
  end

  add_index "freezer_chests", ["bay_id"], name: "index_freezer_chests_on_bay_id", using: :btree

  create_table "import_sheets", force: true do |t|
    t.string   "comment"
    t.string   "filename"
    t.string   "ext"
    t.text     "sheets",      limit: 2147483647
    t.string   "sel_sheets"
    t.string   "category_id"
    t.text     "mapping",     limit: 16777215
    t.string   "imported"
    t.integer  "store_id"
    t.integer  "user_id"
    t.integer  "step",                           default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "manufacturers", force: true do |t|
    t.string   "name"
    t.string   "category_id"
    t.string   "desc"
    t.string   "color"
    t.integer  "import_id",    default: -1
    t.datetime "discard_from"
    t.integer  "discard_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "manufacturers", ["discard_from"], name: "index_manufacturers_on_discard_from", using: :btree
  add_index "manufacturers", ["import_id"], name: "index_manufacturers_on_import_id", using: :btree
  add_index "manufacturers", ["name", "category_id"], name: "index_manufacturers_on_name_and_category_id", unique: true, using: :btree

  create_table "open_shelves", force: true do |t|
    t.integer  "bay_id"
    t.string   "name"
    t.decimal  "height",       precision: 6, scale: 1,             null: false
    t.decimal  "width",        precision: 6, scale: 1,             null: false
    t.decimal  "depth",        precision: 6, scale: 1,             null: false
    t.decimal  "thick",        precision: 6, scale: 1,             null: false
    t.decimal  "slope",        precision: 4, scale: 1,             null: false
    t.decimal  "riser",        precision: 6, scale: 1,             null: false
    t.integer  "notch_num"
    t.decimal  "from_base",    precision: 6, scale: 1,             null: false
    t.string   "color"
    t.decimal  "from_back",    precision: 6, scale: 1,             null: false
    t.decimal  "finger_space", precision: 6, scale: 1,             null: false
    t.decimal  "x_position",   precision: 6, scale: 1,             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",                                default: 0, null: false
  end

  add_index "open_shelves", ["bay_id"], name: "index_open_shelves_on_bay_id", using: :btree

  create_table "peg_boards", force: true do |t|
    t.integer  "bay_id"
    t.string   "name"
    t.decimal  "height",     precision: 6, scale: 1,             null: false
    t.decimal  "depth",      precision: 6, scale: 1,             null: false
    t.decimal  "vert_space", precision: 6, scale: 1,             null: false
    t.decimal  "horz_space", precision: 6, scale: 1,             null: false
    t.decimal  "vert_start", precision: 6, scale: 1,             null: false
    t.decimal  "horz_start", precision: 6, scale: 1,             null: false
    t.integer  "notch_num"
    t.decimal  "from_base",  precision: 6, scale: 1,             null: false
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",                              default: 0, null: false
  end

  add_index "peg_boards", ["bay_id"], name: "index_peg_boards_on_bay_id", using: :btree

  create_table "products", id: false, force: true do |t|
    t.string   "code",                                                    null: false
    t.string   "category_id"
    t.integer  "brand_id"
    t.integer  "mfr_id"
    t.integer  "user_id"
    t.integer  "import_id",                               default: -1
    t.string   "name"
    t.decimal  "height",         precision: 10, scale: 0
    t.decimal  "width",          precision: 10, scale: 0
    t.decimal  "depth",          precision: 10, scale: 0
    t.decimal  "weight",         precision: 10, scale: 0
    t.string   "price_level"
    t.string   "size_name"
    t.string   "case_pack_name"
    t.string   "barcode"
    t.string   "color"
    t.datetime "discard_from"
    t.integer  "discard_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.integer  "sale_type",                               default: 1
    t.boolean  "new_product",                             default: false
    t.boolean  "on_promotion",                            default: false
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["code"], name: "index_products_on_code", unique: true, using: :btree
  add_index "products", ["discard_from"], name: "index_products_on_discard_from", using: :btree
  add_index "products", ["import_id"], name: "index_products_on_import_id", using: :btree
  add_index "products", ["name", "category_id"], name: "index_products_on_name_and_category_id", using: :btree
  add_index "products", ["supplier_id"], name: "by_supplier", using: :btree

  create_table "rear_support_bars", force: true do |t|
    t.integer  "bay_id"
    t.string   "name"
    t.decimal  "height",      precision: 6, scale: 1,             null: false
    t.decimal  "bar_depth",   precision: 6, scale: 1,             null: false
    t.decimal  "bar_thick",   precision: 6, scale: 1,             null: false
    t.decimal  "from_back",   precision: 6, scale: 1,             null: false
    t.decimal  "hook_length", precision: 6, scale: 1,             null: false
    t.integer  "notch_num"
    t.decimal  "from_base",   precision: 6, scale: 1,             null: false
    t.string   "color"
    t.decimal  "bar_slope",   precision: 4, scale: 1,             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",                               default: 0, null: false
  end

  add_index "rear_support_bars", ["bay_id"], name: "index_rear_support_bars_on_bay_id", using: :btree

  create_table "regions", id: false, force: true do |t|
    t.string   "code",                                  null: false
    t.string   "name",                                  null: false
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "consume_type", limit: 32, default: "B", null: false
  end

  add_index "regions", ["code"], name: "index_regions_on_code", unique: true, using: :btree
  add_index "regions", ["consume_type"], name: "index_regions_on_consume_type", using: :btree
  add_index "regions", ["name"], name: "index_regions_on_name", using: :btree

  create_table "sales", force: true do |t|
    t.string   "product_id",                                        null: false
    t.integer  "store_id"
    t.integer  "num_stores",                           default: 1
    t.integer  "user_id"
    t.integer  "import_id",                            default: -1
    t.decimal  "price",       precision: 10, scale: 2
    t.integer  "facing"
    t.decimal  "run",         precision: 10, scale: 2
    t.integer  "volume"
    t.integer  "volume_rank"
    t.decimal  "value",       precision: 10, scale: 0
    t.integer  "value_rank"
    t.decimal  "margin",      precision: 10, scale: 0
    t.integer  "margin_rank"
    t.decimal  "psi",         precision: 7,  scale: 3
    t.integer  "psi_rank"
    t.integer  "psi_rule_id"
    t.integer  "rcmd_facing"
    t.integer  "job_id",                               default: -1
    t.text     "detail"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sales", ["ended_at"], name: "index_sales_on_ended_at", using: :btree
  add_index "sales", ["import_id"], name: "index_sales_on_import_id", using: :btree
  add_index "sales", ["job_id"], name: "index_sales_on_job_id", using: :btree
  add_index "sales", ["product_id"], name: "index_sales_on_product_id", using: :btree
  add_index "sales", ["started_at"], name: "index_sales_on_started_at", using: :btree
  add_index "sales", ["store_id"], name: "index_sales_on_store_id", using: :btree
  add_index "sales", ["updated_at"], name: "index_sales_on_updated_at", using: :btree

  create_table "stores", force: true do |t|
    t.string   "region_id",                            null: false
    t.string   "name"
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",         limit: 48
    t.integer  "ref_store_id"
    t.integer  "area"
    t.string   "location",     limit: 32
    t.integer  "import_id",               default: -1
  end

  add_index "stores", ["area"], name: "index_stores_on_area", using: :btree
  add_index "stores", ["code"], name: "index_stores_on_code", unique: true, using: :btree
  add_index "stores", ["location"], name: "index_stores_on_location", using: :btree
  add_index "stores", ["name"], name: "index_stores_on_name", using: :btree
  add_index "stores", ["ref_store_id"], name: "index_stores_on_ref_store_id", using: :btree
  add_index "stores", ["region_id"], name: "index_stores_on_region_id", using: :btree

  create_table "suppliers", force: true do |t|
    t.string   "name"
    t.string   "category_id"
    t.string   "desc"
    t.string   "color"
    t.integer  "import_id",    default: -1
    t.datetime "discard_from"
    t.integer  "discard_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suppliers", ["discard_from"], name: "index_suppliers_on_discard_from", using: :btree
  add_index "suppliers", ["import_id"], name: "index_suppliers_on_import_id", using: :btree
  add_index "suppliers", ["name", "category_id"], name: "index_suppliers_on_name_and_category_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
