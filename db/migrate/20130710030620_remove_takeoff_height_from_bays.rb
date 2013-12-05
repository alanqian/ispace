class RemoveTakeoffHeightFromBays < ActiveRecord::Migration
  def change
    remove_column :bays, :takeoff_height, :decimal
  end
end
