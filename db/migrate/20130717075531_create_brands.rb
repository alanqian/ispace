class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.string :category_id
      t.string :color

      t.timestamps
      t.index [:name, :category_id], unique: true
    end
  end
end
