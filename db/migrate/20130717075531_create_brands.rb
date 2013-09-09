class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.string :category_id
      t.string :color
      t.integer :import_id, :default => -1
      t.datetime :discard_from
      t.integer :discard_by

      t.timestamps
      t.index [:name, :category_id], unique: true
      t.index :import_id, unique: false
      t.index :discard_from, unique: false
    end
  end
end