class AddProductGrade < ActiveRecord::Migration
  def change
    add_column :products, :grade, :string, null: false, default: "B"
    remove_column :products, :sale_type
    add_index :products, [:category_id, :grade], unique: false
  end
end
