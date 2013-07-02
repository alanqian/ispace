class FreezerChest < ActiveRecord::Base
  belongs_to :bay, :class_name => Bay

  validates :name, presence: true, length: { maximum: 64 }
  validates :height, :depth, :wall_thick, :inside_height, :merch_height, presence: true,
    numericality: { greater_than_or_equal_to: 0.1 }

  validates :color, presence: true, format: { with: %r/#[0-9a-fA-F]{1,6}/,
    message: 'color' }

  def from_base
    0.0
  end
end
