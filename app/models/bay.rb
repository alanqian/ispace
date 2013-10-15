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

  alias_attribute :run, :back_width
  attr_accessor :use_notch, :show_peg_holes

  def use_notch
    true
  end
  def show_peg_holes
    true
  end

  def to_notch(from_base)
    (from_base - notch_1st) / notch_spacing
  end

  def get_element(layer)
    open_shelves.where(level: layer).first ||
    peg_boards.where(level: layer).first ||
    freezer_chests.where(level: layer).first ||
    rear_support_bars.where(level: layer).first
  end

  # origin: left/bottom corner
  def to_pdf(pdf, ostate)
    num_bays = ostate.fixture[:num_bays]
    case ostate.fixture[:bay]
    when :front_view
      # move origin to base
      ostate.origin[1] += base_height * ostate.scale

      # draw layers, space without fill, shelf with fill
      layers.each do |layer|
        ostate.fixture[:layer] = :layout
        layer.to_pdf(pdf, ostate)

        # output text of each layer
        ostate.fixture[:layer] = :text
        layer.to_pdf(pdf, ostate)

        ostate.fixture[:layer] = ostate.fixture[:contains]
        layer.to_pdf(pdf, ostate)
      end

      # draw base with fill color
      pdf.fill_color(base_color)
      origin = ostate.origin.dup
      cx = base_width * ostate.scale
      num_bays.times do
        pdf.fill_and_stroke_rectangle origin, cx, base_height * ostate.scale
        origin[0] += cx
      end

      # restore origin
      ostate.origin[1] -= base_height * ostate.scale
    end
  end

  def layers
    elems = []
    elems.concat open_shelves
    elems.concat peg_boards
    elems.concat freezer_chests
    elems.concat rear_support_bars
    elems.sort { |a,b| b.level <=> a.level }
  end

  # for notch_num
  # from_base = (notch_num - 1) * notch_spacing + notch_first
  def notch_to(notch_num)
    (notch_num - 1) * notch_spacing + notch_1st
  end

  # take off height: only for open_shelf, guide line for designer
  # from floor up to top of open_shelf
  # take_off_height = base_height + MAX(from_base + height)
  def takeoff_height
    top_shelf = open_shelves.order('from_base desc').first
    if top_shelf
      return base_height + top_shelf.from_base + top_shelf.height
    else
      return base_height
    end
  end

  def max_height
    back_height + base_height
  end

  def max_width
    widths = [base_width, back_width]
    [open_shelves, peg_boards, freezer_chests, rear_support_bars].each do |els|
      els.each do |el|
        widths.push el.width
      end
    end
    widths.max
  end

  # fake attr writer
  def takeoff_height=(val)
  end

  # helper for seeds.rb
  def recalc_space
    self.linear = 0.0
    self.area = 0.0
    self.cube = 0.0
    open_shelves.each do |el|
      self.linear += el.width
      self.area += el.width * el.height
      self.cube += el.width * el.height * el.depth
    end
    save
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
