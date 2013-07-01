class CreateRearSupportBars < ActiveRecord::Migration
  def change
    create_table :rear_support_bars do |t|
      t.integer :bay_id
      t.integer :level
      t.string :name, :length => 32
      t.decimal :height, :precision => 6, :scale => 1, :null => false
      t.decimal :bar_depth, :precision => 6, :scale => 1, :null => false
      t.decimal :bar_thick, :precision => 6, :scale => 1, :null => false
      t.decimal :from_back, :precision => 6, :scale => 1, :null => false
      t.decimal :hook_length, :precision => 6, :scale => 1, :null => false
      t.integer :notch_num
      t.decimal :from_base, :precision => 6, :scale => 1, :null => false
      t.string :color
      t.decimal :bar_slope, :precision => 4, :scale => 1, :null => false

      t.timestamps
    end
  end
end
