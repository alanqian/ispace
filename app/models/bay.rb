class Bay < ActiveRecord::Base
  has_many :open_shelves
  accepts_nested_attributes_for :open_shelves, allow_destroy: true
  validates :name, :presence => true
  validates :back_height, :back_width, :back_thick, :back_color, :presence => true
  validates :notch_spacing, :notch_1st, :presence => true
  validates :base_height, :base_width, :base_depth, :base_color, :presence => true
  # takeoff_height, precision: 6, scale: 1
  # elem_type
  # elem_count
end
