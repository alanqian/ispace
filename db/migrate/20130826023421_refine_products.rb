class RefineProducts < ActiveRecord::Migration
  def up
    add_column :products, :supplier_id, :integer
    add_column :products, :sale_type, :integer, default: 1
    add_column :products, :new_product, :boolean, default: false
    add_column :products, :on_promotion, :boolean, default: false
    add_index(:products, [:supplier_id], name: 'by_supplier')
  end

  def down
    remove_index :products, name: :by_supplier
    remove_column :products, :supplier_id
    remove_column :products, :sale_type
    remove_column :products, :new_product
    remove_column :products, :on_promotion
  end
end
