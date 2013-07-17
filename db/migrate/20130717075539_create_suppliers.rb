class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :name
      t.string :category_id
      t.string :desc
      t.string :color

      t.timestamps
      t.index [:name, :category_id], unique: true
    end
  end
end
