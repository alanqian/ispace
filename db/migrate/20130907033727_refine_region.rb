class RefineRegion < ActiveRecord::Migration
  def up
    add_column :regions, :consume_type, :string, limit: 32, null: false, default: "B"
    rename_column :regions, :desc, :memo
    add_index :regions, [:consume_type], unique:false
  end

  def down
    rename_column :regions, :memo, :desc
    remove_column :regions, :consume_type
  end
end
