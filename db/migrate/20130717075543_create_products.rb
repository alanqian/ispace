class CreateProducts < ActiveRecord::Migration
  def change
    create_table(:products, id: false) do |t|
      t.string :code, :length => 80, :null => false
      t.string :category_id
      t.integer :brand_id
      t.integer :mfr_id
      t.integer :user_id
      t.integer :import_id, :default => -1
      t.string :name
      t.decimal :height
      t.decimal :width
      t.decimal :depth
      t.decimal :weight
      t.string :price_level
      t.string :size_name
      t.string :case_pack_name
      t.string :bar_code
      t.string :color

      t.timestamps
      t.index [:name, :category_id], unique: false
      t.index :import_id, unique: false
      t.index :category_id
    end
    execute "ALTER TABLE products ADD PRIMARY KEY (code);"
  end
end
