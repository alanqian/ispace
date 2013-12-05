class CreateBays < ActiveRecord::Migration
  def change
    create_table :bays do |t|
      t.string :name, :length => 40, :null => false
      t.decimal :back_height, :precision => 6, :scale => 1, :null => false
      t.decimal :back_width, :precision => 7, :scale => 1, :null => false
      t.decimal :back_thick, :precision => 6, :scale => 1, :null => false
      t.string :back_color, :null => false
      t.decimal :notch_spacing, :precision => 6, :scale => 1
      t.decimal :notch_1st, :precision => 6, :scale => 1
      t.decimal :base_height, :precision => 6, :scale => 1, :null => false
      t.decimal :base_width, :precision => 6, :scale => 1, :null => false
      t.decimal :base_depth, :precision => 6, :scale => 1, :null => false
      t.string :base_color, :null => false
      t.decimal :takeoff_height, :precision => 6, :scale => 1
      t.integer :elem_type
      t.integer :elem_count

      t.timestamps
    end
  end
end
