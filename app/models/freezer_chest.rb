class FreezerChest < ActiveRecord::Base
  belongs_to :bay, :class_name => Bay

  validates :name, presence: true, length: { maximum: 64 }
  validates :height, :depth, :wall_thick, :inside_height, :merch_height, presence: true,
    numericality: { greater_than_or_equal_to: 0.1 }

  validates :color, presence: true, format: { with: %r/#[0-9a-fA-F]{1,6}/,
    message: 'color' }

  attr_accessor :from_base, :notch_num
  def from_base
    0.0
  end
  def notch_num
    1
  end
end
