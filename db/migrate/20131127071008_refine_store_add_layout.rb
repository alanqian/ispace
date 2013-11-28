class RefineStoreAddLayout < ActiveRecord::Migration
  def up
    add_column :stores, :deleted_at, :datetime
    add_column :stores, :image_file, :string
    change_column :stores, :grade, :string, limit: 2, null: false, default: 'B'
  end

  def down
    remove_column :stores, :deleted_at
    remove_column :stores, :image_file
  end
end
