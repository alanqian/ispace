class OpenShelf < ActiveRecord::Base
  @@template_id = 0   # TODO: load from conf
  belongs_to :bay, :class_name => Bay

  validates :name, presence: true, length: { maximum: 64 }
  validates :height, :width, :depth, :thick, presence: true,
    numericality: { greater_than_or_equal_to: 0.1 }
  validates :slope, :riser, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }

  validates :notch_num, presence: true,
    numericality: { greater_than_or_equal_to: 0 }
  validates :from_base, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }

  validates :color, presence: true, format: { with: %r/#[0-9a-fA-F]{1,6}/,
    message: 'color' }

  validates :from_back, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }
  validates :finger_space, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }
  validates :x_position, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }

  def self.template(bay)
    r = self.where(bay_id: -1).first
    if r
      r.bay_id = bay.id
      r.width = bay.back_width
      r.depth = bay.base_depth
    end
    r
  end
end
