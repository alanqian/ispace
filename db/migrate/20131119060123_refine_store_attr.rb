class RefineStoreAttr < ActiveRecord::Migration
  def up
    add_column :stores, :depot_area, :decimal, precision: 6, scale: 1
    add_column :stores, :grade, :string
    change_column :stores, :area, :decimal, precision: 6, scale: 1
  end

  def down
    remove_column :stores, :depot_area
    remove_column :stores, :grade
    change_column :stores, :area, :integer
  end
end
