class CreateImportSheet < ActiveRecord::Migration
  def change
    create_table :import_sheets do |t|
      t.string   "comment"
      t.string   "filename"
      t.string   "ext"
      t.text     "sheets", limit: 20 * 1024 * 1024
      t.string   "sel_sheets"
      t.string   "category_id", length: 64
      t.text     "mapping", limit: 64 * 1024
      t.string   "imported"
      t.integer  "store_id"
      t.integer  "user_id"
      t.integer  "step", default: 1
      t.timestamps
    end
  end
end
