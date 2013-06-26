class CreateOpenShelves < ActiveRecord::Migration
  def change
    create_table :open_shelves do |t|
      t.integer :bay_id
      t.integer :level
      t.string :name, :length => 32
      t.decimal :height, :precision => 6, :scale => 1, :null => false
      t.decimal :width, :precision => 6, :scale => 1, :null => false
      t.decimal :depth, :precision => 6, :scale => 1, :null => false
      t.decimal :thick, :precision => 6, :scale => 1, :null => false
      t.decimal :slope, :precision => 4, :scale => 1, :null => false
      t.decimal :riser, :precision => 6, :scale => 1, :null => false
      t.integer :notch_num
      t.decimal :from_base, :precision => 6, :scale => 1, :null => false
      t.string :color
      t.decimal :from_back, :precision => 6, :scale => 1, :null => false
      t.decimal :finger_space, :precision => 6, :scale => 1, :null => false
      t.decimal :x_positon, :precision => 6, :scale => 1, :null => false

      t.timestamps
    end
  end
end
