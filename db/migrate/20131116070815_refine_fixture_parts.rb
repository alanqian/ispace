class RefineFixtureParts < ActiveRecord::Migration
  def change
    rename_column :store_fixtures, :layers, :parts
    rename_column :plans, :layers, :parts
    add_column :store_fixtures, :memo, :string
  end
end
