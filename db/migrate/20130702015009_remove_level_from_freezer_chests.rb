class RemoveLevelFromFreezerChests < ActiveRecord::Migration
  def change
    remove_column :freezer_chests, :level, :integer
  end
end
