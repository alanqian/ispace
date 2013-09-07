class RefineStore < ActiveRecord::Migration
  def up
    add_column :stores, :code, :string, limit:48
    add_column :stores, :ref_store_id, :integer
    add_column :stores, :area, :integer
    add_column :stores, :location, :string, limit:32
    add_column :stores, :import_id, :integer, default:-1
    rename_column :stores, :desc, :memo

    add_index :stores, [:code], unique:true
    add_index :stores, [:ref_store_id]
    add_index :stores, [:area]
    add_index :stores, [:location]
  end

  def down
    remove_column :stores, :code
    remove_column :stores, :ref_store_id
    remove_column :stores, :area
    remove_column :stores, :location
    remove_column :stores, :import_id
    rename_column :stores, :memo, :desc
  end
end


