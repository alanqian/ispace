class ChangeUnitToMm < ActiveRecord::Migration
  def up
    change_column :bays, :back_height, :integer, null: false
    change_column :bays, :back_width, :integer, null: false
    change_column :bays, :back_thick, :integer, null: false
    change_column :bays, :notch_spacing, :integer, null: false, default: 20
    change_column :bays, :notch_1st, :integer, null: false, default: 20
    change_column :bays, :base_height, :integer, null: false
    change_column :bays, :base_width, :integer, null: false
    change_column :bays, :base_depth, :integer, null: false

    change_column :open_shelves, :height,       :integer, null: false
    change_column :open_shelves, :width,        :integer, null: false
    change_column :open_shelves, :depth,        :integer, null: false
    change_column :open_shelves, :thick,        :integer, null: false
    change_column :open_shelves, :riser,        :integer, null: false
    change_column :open_shelves, :from_base,    :integer, null: false
    change_column :open_shelves, :from_back,    :integer, null: false
    change_column :open_shelves, :finger_space, :integer, null: false
    change_column :open_shelves, :x_position,   :integer, null: false

    change_column :peg_boards, :height,     :integer, null: false
    change_column :peg_boards, :depth,      :integer, null: false
    change_column :peg_boards, :vert_space, :integer, null: false
    change_column :peg_boards, :horz_space, :integer, null: false
    change_column :peg_boards, :vert_start, :integer, null: false
    change_column :peg_boards, :horz_start, :integer, null: false
    change_column :peg_boards, :from_base,  :integer, null: false

    change_column :rear_support_bars, :height,      :integer, null: false
    change_column :rear_support_bars, :bar_depth,   :integer, null: false
    change_column :rear_support_bars, :bar_thick,   :integer, null: false
    change_column :rear_support_bars, :from_back,   :integer, null: false
    change_column :rear_support_bars, :hook_length, :integer, null: false
    change_column :rear_support_bars, :from_base,   :integer, null: false
    change_column :rear_support_bars, :bar_slope,   :integer, null: false

    change_column :freezer_chests, :height,        :integer, null: false
    change_column :freezer_chests, :depth,         :integer, null: false
    change_column :freezer_chests, :wall_thick,    :integer, null: false
    change_column :freezer_chests, :inside_height, :integer, null: false
    change_column :freezer_chests, :merch_height,  :integer, null: false

    change_column :products, :height, :integer, null: false
    change_column :products, :width, :integer, null: false
    change_column :products, :depth, :integer, null: false
    change_column :products, :grade, :string, limit: 2, null: false

    change_column :positions,:run,              :integer
    change_column :positions,:top_cap_width,    :integer
    change_column :positions,:top_cap_depth,    :integer
    change_column :positions,:bottom_cap_width, :integer
    change_column :positions,:bottom_cap_depth, :integer
    change_column :positions,:left_cap_width,   :integer
    change_column :positions,:left_cap_depth,   :integer
    change_column :positions,:right_cap_width,  :integer
    change_column :positions,:right_cap_depth,  :integer
    change_column :positions,:leading_gap,      :integer
    change_column :positions,:leading_divider,  :integer
    change_column :positions,:middle_divider,   :integer
    change_column :positions,:trail_divider,    :integer

    change_column :sales, :run, :integer
  end

  def down
  end
end
