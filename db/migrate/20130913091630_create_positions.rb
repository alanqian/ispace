class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.integer :plan_id
      t.integer :store_id
      t.integer :product_id
      t.integer :layer
      t.integer :seq_num
      t.integer :facing
      t.decimal :run, precision: 10, scale: 1
      t.integer :units
      t.integer :height_units
      t.integer :width_units
      t.integer :depth_units
      t.string :oritentation
      t.string :merch_style
      t.string :peg_style
      t.decimal :top_cap_width, precision: 10, scale: 1
      t.decimal :top_cap_depth, precision: 10, scale: 1
      t.decimal :bottom_cap_width, precision: 10, scale: 1
      t.decimal :bottom_cap_depth, precision: 10, scale: 1
      t.decimal :left_cap_width, precision: 10, scale: 1
      t.decimal :left_cap_depth, precision: 10, scale: 1
      t.decimal :right_cap_width, precision: 10, scale: 1
      t.decimal :right_cap_depth, precision: 10, scale: 1
      t.decimal :leading_gap, precision: 10, scale: 1
      t.decimal :leading_divider, precision: 10, scale: 1
      t.decimal :middle_divider, precision: 10, scale: 1
      t.decimal :trail_divider, precision: 10, scale: 1

      t.timestamps
    end
  end
end
