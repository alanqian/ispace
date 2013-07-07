class Bay < ActiveRecord::Base
  has_many :fixture_items

  has_many :open_shelves
  has_many :peg_boards
  has_many :freezer_chests
  has_many :rear_support_bars
  accepts_nested_attributes_for :open_shelves, allow_destroy: true
  accepts_nested_attributes_for :peg_boards, allow_destroy: true
  accepts_nested_attributes_for :freezer_chests, allow_destroy: true
  accepts_nested_attributes_for :rear_support_bars, allow_destroy: true

  validates :name, presence: true, length: { maximum: 64 }
  validates :back_height, :back_width, :back_thick, presence: true,
    numericality: { greater_than: 0.1 }
  validates :back_color, presence: true, format: { with: %r/#[0-9a-fA-F]{1,6}/,
    message: 'color' }

  validates :notch_spacing, :notch_1st, presence: true,
    numericality: { greater_than_or_equal_to: 1.0 }
  validates :base_height, :base_width, :base_depth, presence: true,
    numericality: { greater_than: 0.1 }
  validates :base_color, presence: true, format: { with: %r/#[0-9a-fA-F]{1,6}/ }

  validates :takeoff_height, presence: true,
    numericality: { greater_than_or_equal_to: 0.0 }
  # elem_type
  # elem_count

  attr_accessor :use_notch, :show_peg_holes
  attr_reader :run, :liear, :area, :cube

  def use_notch
    true
  end
  def show_peg_holes
    true
  end

  def to_notch(from_base)
    (from_base - notch_1st) / notch_spacing
  end

  # for notch_num
  # from_base = (notch_num - 1) * notch_spacing + notch_first
  def notch_to(notch_num)
    (notch_num - 1) * notch_spacing + notch_1st
  end

  def run
    base_width
  end

  def liear
    base_width * elem_count
  end

  def area
    base_width * base_depth * elem_count
  end

  def cube
    base_width * base_depth * back_height
  end

  def self.template
    bay = self.new(
      name: 'bay ',
      back_height: 185.0,
      back_width: 120.0,
      back_thick: 3.0,
      back_color: '#ffffff',
      notch_spacing: 1.0,
      notch_1st: 1.0,
      base_height: 15.0,
      base_width: 120.0,
      base_depth: 50.0,
      base_color: '#400040',
      takeoff_height: 190.0,
      elem_type: 1,
      elem_count: 1
    )
    bay.open_shelves.concat(OpenShelf.template(bay))
    bay
  end

  def deep_copy
    # copy self
    new_bay = self.dup # shallow copy
    new_bay.name += "(copy)"
    new_bay.save!

    # copy associations
    elements = [:open_shelves, :peg_boards, :freezer_chests, :rear_support_bars]
    elements.each { |assoc| copy_assoc_to(new_bay, assoc) }

    new_bay
  end

  private
    def copy_assoc_to(new_bay, assoc_sym)
      self.send(assoc_sym).each do |row|
        new_row = row.dup # shallow copy
        new_bay.send(assoc_sym) << new_row
      end
    end
end
