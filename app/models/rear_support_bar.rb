class RearSupportBar < ActiveRecord::Base
  belongs_to :bay, :class_name => Bay

  validates :name, presence: true, length: { maximum: 64 }
  validates :height, :bar_depth, :bar_thick, presence: true,
    numericality: { greater_than_or_equal_to: 0.1 }

  validates :from_back, :hook_length, presence: true,
    numericality: { greater_than_or_equal_to: 0.1 }

  validates :notch_num, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :from_base, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }

  validates :color, presence: true, format: { with: %r/#[0-9a-fA-F]{1,6}/,
    message: 'color' }
  validates :bar_slope, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }

  def self.template(bay)
    r = self.where(bay_id: -1).first || self.new
    r.id = nil
    r.bay_id = bay.id
    r
  end

  def merch_width
    bay.back_width
  end

  def shelf_thick
    bar_thick
  end

  alias_attribute :merch_height, :height
end
