class RemoveLevelFromPegBoards < ActiveRecord::Migration
  def change
    remove_column :peg_boards, :level, :integer
  end
end
