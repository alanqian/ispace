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

ActiveRecord::Schema.define(version: 20131129025341) do

  create_table "bays", force: true do |t|
    t.string   "name",                                                null: false
    t.integer  "back_height",                                         null: false
    t.integer  "back_width",                                          null: false
    t.integer  "back_thick",                                          null: false
    t.string   "back_color",                                          null: false
    t.integer  "notch_spacing",                          default: 20, null: false
    t.integer  "notch_1st",                              default: 20, null: false
    t.integer  "base_height",                                         null: false
    t.integer  "base_width",                                          null: false
    t.integer  "base_depth",                                          null: false
    t.string   "base_color",                                          null: false
    t.integer  "num_layers"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "linear",        precision: 10, scale: 0
    t.decimal  "area",          precision: 10, scale: 0
    t.decimal  "cube",          precision: 10, scale: 0
    t.datetime "deleted_at"
    t.string   "types"
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
    t.string   "name",                                 null: false
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",         limit: 32,              null: false
    t.string   "parent_id",    limit: 32
    t.integer  "import_id",               default: -1
    t.string   "pinyin"
    t.string   "display_name"
  end

  add_index "categories", ["code"], name: "index_categories_on_code", unique: true, using: :btree
  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deployments", force: true do |t|
    t.integer  "plan_id"
    t.integer  "store_id"
    t.integer  "downloaded_by"
    t.datetime "downloaded_at"
    t.datetime "deployed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "store_name",                             null: false
    t.integer  "plan_set_id",                            null: false
    t.string   "plan_set_name"
    t.string   "plan_set_note"
    t.datetime "published_at",                           null: false
    t.date     "to_deploy_at",    default: '2013-11-07', null: false
    t.datetime "download_1st_at"
    t.integer  "download_count",  default: 0
    t.integer  "deployed_by",     default: 0
    t.integer  "discarded_by"
    t.datetime "discarded_at"
  end

  add_index "deployments", ["deployed_at"], name: "index_deployments_on_deployed_at", using: :btree
  add_index "deployments", ["downloaded_at"], name: "index_deployments_on_downloaded_at", using: :btree
  add_index "deployments", ["plan_id"], name: "index_deployments_on_plan_id", using: :btree
  add_index "deployments", ["plan_set_id"], name: "index_deployments_on_plan_set_id", using: :btree
  add_index "deployments", ["store_id"], name: "index_deployments_on_store_id", using: :btree

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
    t.boolean  "flow_l2r"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "memo"
  end

  add_index "fixtures", ["name"], name: "index_fixtures_on_name", using: :btree
  add_index "fixtures", ["user_id"], name: "index_fixtures_on_user_id", using: :btree

  create_table "freezer_chests", force: true do |t|
    t.integer  "bay_id"
    t.string   "name"
    t.integer  "height",                    null: false
    t.integer  "depth",                     null: false
    t.integer  "wall_thick",                null: false
    t.integer  "inside_height",             null: false
    t.integer  "merch_height",              null: false
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",         default: 0, null: false
  end

  add_index "freezer_chests", ["bay_id"], name: "index_freezer_chests_on_bay_id", using: :btree

  create_table "import_sheets", force: true do |t|
    t.string   "comment"
    t.string   "filename"
    t.string   "type",       limit: 48
    t.text     "sheets",     limit: 2147483647
    t.text     "mapping",    limit: 16777215
    t.text     "imported"
    t.integer  "store_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "done",       limit: 48
  end

  add_index "import_sheets", ["type"], name: "index_import_sheets_on_type", using: :btree
  add_index "import_sheets", ["updated_at"], name: "index_import_sheets_on_updated_at", using: :btree

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
    t.integer  "height",                                           null: false
    t.integer  "width",                                            null: false
    t.integer  "depth",                                            null: false
    t.integer  "thick",                                            null: false
    t.decimal  "slope",        precision: 4, scale: 1,             null: false
    t.integer  "riser",                                            null: false
    t.integer  "notch_num"
    t.integer  "from_base",                                        null: false
    t.string   "color"
    t.integer  "from_back",                                        null: false
    t.integer  "finger_space",                                     null: false
    t.integer  "x_position",                                       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",                                default: 0, null: false
  end

  add_index "open_shelves", ["bay_id"], name: "index_open_shelves_on_bay_id", using: :btree

  create_table "peg_boards", force: true do |t|
    t.integer  "bay_id"
    t.string   "name"
    t.integer  "height",                 null: false
    t.integer  "depth",                  null: false
    t.integer  "vert_space",             null: false
    t.integer  "horz_space",             null: false
    t.integer  "vert_start",             null: false
    t.integer  "horz_start",             null: false
    t.integer  "notch_num"
    t.integer  "from_base",              null: false
    t.string   "color"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",      default: 0, null: false
  end

  add_index "peg_boards", ["bay_id"], name: "index_peg_boards_on_bay_id", using: :btree

  create_table "plan_sets", force: true do |t|
    t.string   "name",                                                      null: false
    t.string   "note"
    t.string   "category_id",                                               null: false
    t.integer  "user_id"
    t.integer  "num_plans",                          default: 0
    t.integer  "num_stores",                         default: 0
    t.datetime "published_at"
    t.integer  "undeployed_stores"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "category_name"
    t.date     "to_deploy_at",                       default: '2013-11-07', null: false
    t.text     "recent_plans",      limit: 16777215
  end

  add_index "plan_sets", ["category_id"], name: "index_plan_sets_on_category_id", using: :btree
  add_index "plan_sets", ["created_at"], name: "index_plan_sets_on_created_at", using: :btree
  add_index "plan_sets", ["name"], name: "index_plan_sets_on_name", using: :btree
  add_index "plan_sets", ["published_at"], name: "index_plan_sets_on_published_at", using: :btree
  add_index "plan_sets", ["undeployed_stores"], name: "index_plan_sets_on_undeployed_stores", using: :btree
  add_index "plan_sets", ["user_id"], name: "index_plan_sets_on_user_id", using: :btree

  create_table "plans", force: true do |t|
    t.integer  "plan_set_id",                                                            null: false
    t.string   "category_id",                                                            null: false
    t.integer  "user_id"
    t.integer  "store_id",                                                               null: false
    t.integer  "num_stores",                                               default: 0
    t.integer  "fixture_id",                                                             null: false
    t.integer  "init_facing",                                              default: 1
    t.decimal  "nominal_size",                    precision: 10, scale: 2
    t.decimal  "base_footage",                    precision: 10, scale: 2
    t.decimal  "usage_percent",                   precision: 10, scale: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "product_version",                                          default: 0
    t.string   "store_name"
    t.integer  "num_prior_products",                                       default: 0
    t.integer  "num_normal_products",                                      default: 0
    t.integer  "num_done_priors",                                          default: 0
    t.integer  "num_done_normals",                                         default: 0
    t.integer  "fixture_version"
    t.string   "parts",               limit: 512
    t.integer  "version",                                                  default: 0,   null: false
    t.string   "min_product_grade",   limit: 2,                            default: "Q", null: false
  end

  add_index "plans", ["category_id"], name: "index_plans_on_category_id", using: :btree
  add_index "plans", ["fixture_id"], name: "index_plans_on_fixture_id", using: :btree
  add_index "plans", ["plan_set_id", "store_id"], name: "index_plans_on_plan_set_id_and_store_id", unique: true, using: :btree
  add_index "plans", ["plan_set_id"], name: "index_plans_on_plan_set_id", using: :btree
  add_index "plans", ["store_id"], name: "index_plans_on_store_id", using: :btree
  add_index "plans", ["user_id"], name: "index_plans_on_user_id", using: :btree

  create_table "positions", force: true do |t|
    t.integer  "plan_id"
    t.integer  "store_id"
    t.string   "product_id",                    null: false
    t.integer  "layer"
    t.integer  "seq_num"
    t.integer  "facing"
    t.integer  "run"
    t.integer  "units"
    t.integer  "height_units"
    t.integer  "width_units"
    t.integer  "depth_units"
    t.string   "oritentation"
    t.string   "merch_style"
    t.string   "peg_style"
    t.integer  "top_cap_width"
    t.integer  "top_cap_depth"
    t.integer  "bottom_cap_width"
    t.integer  "bottom_cap_depth"
    t.integer  "left_cap_width"
    t.integer  "left_cap_depth"
    t.integer  "right_cap_width"
    t.integer  "right_cap_depth"
    t.integer  "leading_gap"
    t.integer  "leading_divider"
    t.integer  "middle_divider"
    t.integer  "trail_divider"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fixture_item_id",  default: -1, null: false
    t.integer  "init_facing",                   null: false
    t.integer  "version",          default: 0,  null: false
  end

  create_table "products", id: false, force: true do |t|
    t.string   "code",                                                                    null: false
    t.string   "category_id"
    t.integer  "brand_id"
    t.integer  "mfr_id"
    t.integer  "user_id"
    t.integer  "import_id",                                               default: -1
    t.string   "name"
    t.integer  "height",                                                                  null: false
    t.integer  "width",                                                                   null: false
    t.integer  "depth",                                                                   null: false
    t.decimal  "weight",                         precision: 10, scale: 0
    t.string   "price_zone"
    t.string   "size_name"
    t.string   "case_pack_name"
    t.string   "barcode"
    t.string   "color"
    t.datetime "discard_from"
    t.integer  "discard_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "supplier_id"
    t.boolean  "new_product",                                             default: false
    t.boolean  "on_promotion",                                            default: false
    t.string   "abbr_name"
    t.string   "en_name"
    t.string   "unit"
    t.integer  "pack_units"
    t.string   "sale_season"
    t.integer  "shelf_life"
    t.string   "tax_type"
    t.decimal  "input_price",                    precision: 15, scale: 4
    t.decimal  "input_price_with_tax",           precision: 15, scale: 4
    t.decimal  "input_tax_ratio",                precision: 5,  scale: 3
    t.decimal  "output_tax_ratio",               precision: 5,  scale: 3
    t.decimal  "input_sale_price",               precision: 15, scale: 4
    t.decimal  "input_member_price",             precision: 15, scale: 4
    t.integer  "shelf_life_input"
    t.integer  "shelf_life_dist"
    t.integer  "available"
    t.integer  "status"
    t.string   "grade",                limit: 2,                          default: "B",   null: false
  end

  add_index "products", ["category_id", "grade"], name: "index_products_on_category_id_and_grade", using: :btree
  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["code"], name: "index_products_on_code", unique: true, using: :btree
  add_index "products", ["discard_from"], name: "index_products_on_discard_from", using: :btree
  add_index "products", ["import_id"], name: "index_products_on_import_id", using: :btree
  add_index "products", ["name", "category_id"], name: "index_products_on_name_and_category_id", using: :btree
  add_index "products", ["supplier_id"], name: "by_supplier", using: :btree

  create_table "rear_support_bars", force: true do |t|
    t.integer  "bay_id"
    t.string   "name"
    t.integer  "height",                  null: false
    t.integer  "bar_depth",               null: false
    t.integer  "bar_thick",               null: false
    t.integer  "from_back",               null: false
    t.integer  "hook_length",             null: false
    t.integer  "notch_num"
    t.integer  "from_base",               null: false
    t.string   "color"
    t.integer  "bar_slope",               null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",       default: 0, null: false
  end

  add_index "rear_support_bars", ["bay_id"], name: "index_rear_support_bars_on_bay_id", using: :btree

  create_table "regions", id: false, force: true do |t|
    t.string   "code",                                  null: false
    t.string   "name",                                  null: false
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "consume_type", limit: 32, default: "B", null: false
    t.integer  "import_id",               default: -1
    t.string   "pinyin"
    t.string   "display_name"
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
    t.integer  "run"
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

  create_table "stats", force: true do |t|
    t.string   "name"
    t.integer  "job_id"
    t.string   "stat_type"
    t.string   "category_id"
    t.integer  "plan_set_id"
    t.string   "rel_model"
    t.integer  "agg_id"
    t.integer  "num_positions"
    t.integer  "run"
    t.integer  "num_facings"
    t.decimal  "outcome",       precision: 15, scale: 4
    t.decimal  "percentage",    precision: 5,  scale: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "store_fixtures", force: true do |t|
    t.string   "code",        null: false
    t.integer  "fixture_id",  null: false
    t.integer  "store_id",    null: false
    t.string   "category_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parts"
    t.string   "passby"
    t.string   "memo"
  end

  add_index "store_fixtures", ["code"], name: "index_store_fixtures_on_code", using: :btree
  add_index "store_fixtures", ["fixture_id"], name: "index_store_fixtures_on_fixture_id", using: :btree
  add_index "store_fixtures", ["store_id", "category_id"], name: "index_store_fixtures_on_store_id_and_category_id", unique: true, using: :btree
  add_index "store_fixtures", ["store_id", "code"], name: "index_store_fixtures_on_store_id_and_code", unique: true, using: :btree

  create_table "stores", force: true do |t|
    t.string   "region_id",                                                     null: false
    t.string   "name"
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "code",         limit: 48
    t.integer  "ref_store_id"
    t.decimal  "area",                    precision: 6, scale: 1
    t.string   "location",     limit: 32
    t.integer  "import_id",                                       default: -1
    t.integer  "ref_count",                                       default: 0
    t.string   "region_name",                                     default: ""
    t.string   "pinyin"
    t.decimal  "depot_area",              precision: 6, scale: 1
    t.string   "grade",        limit: 2,                          default: "B", null: false
    t.datetime "deleted_at"
    t.string   "image_file"
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
    t.string   "username"
    t.string   "employee_id"
    t.string   "telephone"
    t.string   "role"
    t.integer  "store_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
