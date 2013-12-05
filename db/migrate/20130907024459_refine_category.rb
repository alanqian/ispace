class RefineCategory < ActiveRecord::Migration
  def up
    add_column :categories, :code, :string, limit: 32, null:false
    add_column :categories, :parent_id, :string, limit:32, null:true
    rename_column :categories, :desc, :memo
    remove_index :categories, :name
    add_index :categories, [:code], unique:true
    add_index :categories, [:name], unique:true
    add_index :categories, [:parent_id], unique:false
  end

  def down
    remove_column :categories, :code
    remove_column :categories, :parent_id
    rename_column :categories, :memo, :desc
  end
end
