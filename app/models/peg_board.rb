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

  def self.template(bay)
    r = self.where(bay_id: -1).first || self.new
    r.id = nil
    r.bay_id = bay.id
    r.height = bay.back_height
    r
  end

  def merch_width
    bay.back_width
  end

  def shelf_thick
    0
  end

  alias_attribute :merch_height, :height
end
