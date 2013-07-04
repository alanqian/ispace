class Bay < ActiveRecord::Base
  has_many :open_shelves, class_name: OpenShelf
  accepts_nested_attributes_for :open_shelves, allow_destroy: true

  validates :name, presence: true, length: { maximum: 64 }
  validates :back_height, :back_width, :back_thick, presence: true,
    numericality: { greater_than: 0.1 }
  validates :back_color, presence: true, format: { with: %r/#[0-9a-fA-F]{1,6}/,
    message: 'color' }

  validates :notch_spacing, :notch_1st, presence: true,
    numericality: { greater_than: 0.1 }
  validates :base_height, :base_width, :base_depth, presence: true,
    numericality: { greater_than: 0.1 }
  validates :base_color, presence: true, format: { with: %r/#[0-9a-fA-F]{1,6}/ }

  validates :takeoff_height, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }
  # elem_type
  # elem_count

  attr_accessor :use_notch, :show_peg_holes
end
