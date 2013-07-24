class CreateImportSheet < ActiveRecord::Migration
  def change
    create_table :import_sheets do |t|
      t.string   "comment"
      t.string   "filename"
      t.string   "ext"
      t.text     "data", limit: 200 * 1024 * 1024
      t.string   "selected"
      t.string   "mapping"
      t.integer  "store_id"
      t.integer  "user_id"
      t.integer  "step", default: 1
      t.timestamps
    end
  end
end
