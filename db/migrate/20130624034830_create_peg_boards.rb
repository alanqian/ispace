class CreatePegBoards < ActiveRecord::Migration
  def change
    create_table :peg_boards do |t|
      t.integer :bay_id
      t.integer :level
      t.string :name, :length => 32
      t.decimal :height, :precision => 6, :scale => 1, :null => false
      t.decimal :depth, :precision => 6, :scale => 1, :null => false
      t.decimal :vert_space, :precision => 6, :scale => 1, :null => false
      t.decimal :horz_space, :precision => 6, :scale => 1, :null => false
      t.decimal :vert_start, :precision => 6, :scale => 1, :null => false
      t.decimal :horz_start, :precision => 6, :scale => 1, :null => false
      t.integer :notch_num
      t.decimal :from_base, :precision => 6, :scale => 1, :null => false
      t.string :color

      t.timestamps
    end
  end
end
