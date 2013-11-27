class RefineStoreAddLayout < ActiveRecord::Migration
  def change
    add_column :stores, :deleted_at, :datetime
    add_column :stores, :image_file, :string
  end
end
