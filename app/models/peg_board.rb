class PegBoard < ActiveRecord::Base
  belongs_to :bay, :class_name => Bay

  validates :name, presence: true, length: { maximum: 64 }
  validates :height, :depth, presence: true,
    numericality: { greater_than_or_equal_to: 0.1 }

  validates :vert_space, :horz_space, :vert_start, :horz_start, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }

  validates :notch_num, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :from_base, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }

  validates :color, presence: true, format: { with: %r/#[0-9a-fA-F]{1,6}/,
    message: 'color' }
end
