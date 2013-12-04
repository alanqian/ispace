class AddProductImage < ActiveRecord::Migration
  def change
    add_column :products, :image_file, :string
    add_column :products, :merch_style, :string, null: false, default: 'stack'
  end
end
