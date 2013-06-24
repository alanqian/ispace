class CreateFreezerChests < ActiveRecord::Migration
  def change
    create_table :freezer_chests do |t|
      t.integer :bay_id
      t.integer :level
      t.string :name, :length => 32
      t.decimal :height, :precision => 6, :scale => 1, :null => false
      t.decimal :depth, :precision => 6, :scale => 1, :null => false
      t.decimal :inside_height, :precision => 6, :scale => 1, :null => false
      t.decimal :wall_thick, :precision => 6, :scale => 1, :null => false
      t.decimal :merch_height, :precision => 6, :scale => 1, :null => false

      t.timestamps
    end
  end
end
