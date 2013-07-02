class RemoveLevelFromOpenShelves < ActiveRecord::Migration
  def change
    remove_column :open_shelves, :level, :integer
  end
end
