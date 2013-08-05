class CreateManufacturers < ActiveRecord::Migration
  def change
    create_table :manufacturers do |t|
      t.string :name
      t.string :category_id
      t.string :desc
      t.string :color
      t.integer :import_id, :default => -1

      t.timestamps
      t.index [:name, :category_id], unique: true
      t.index :import_id, unique: false
    end
  end
end
