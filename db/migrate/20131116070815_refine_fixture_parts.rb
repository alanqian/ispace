class RefineFixtureParts < ActiveRecord::Migration
  def change
    rename_column :store_fixtures, :layers, :parts
    rename_column :plans, :layers, :parts
  end
end
