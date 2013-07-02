class RemoveLevelFromRearSupportBars < ActiveRecord::Migration
  def change
    remove_column :rear_support_bars, :level, :integer
  end
end
