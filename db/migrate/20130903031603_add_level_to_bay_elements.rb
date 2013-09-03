class AddLevelToBayElements < ActiveRecord::Migration
  def up
    add_column :open_shelves, :level, :integer, null: false, default: 0
    add_column :peg_boards, :level, :integer, null: false, default: 0
    add_column :freezer_chests, :level, :integer, null: false, default: 0
    add_column :rear_support_bars, :level, :integer, null: false, default: 0
  end

  def down
    remove_column :open_shelves, :level
    remove_column :peg_boards, :level
    remove_column :freezer_chests, :level
    remove_column :rear_support_bars, :level
  end
end
