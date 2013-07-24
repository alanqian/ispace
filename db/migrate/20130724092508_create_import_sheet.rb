class CreateImportSheet < ActiveRecord::Migration
  def change
    create_table :import_sheets do |t|
      t.string   "comment"
      t.string   "filename"
      t.string   "ext"
      t.text     "sheets", limit: 20 * 1024 * 1024
      t.text     "selected", limit: 32 * 1024
      t.text     "mapping", limit: 64 * 1024
      t.integer  "store_id"
      t.integer  "user_id"
      t.integer  "step", default: 1
      t.timestamps
    end
  end
end
