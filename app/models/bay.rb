class Bay < ActiveRecord::Base
  default_scope -> { where('deleted_at is NULL') }
  has_many :fixture_items

  has_many :open_shelves
  has_many :peg_boards
  has_many :freezer_chests
  has_many :rear_support_bars
  accepts_nested_attributes_for :open_shelves, allow_destroy: true
  accepts_nested_attributes_for :peg_boards, allow_destroy: true
  accepts_nested_attributes_for :freezer_chests, allow_destroy: true
  accepts_nested_attributes_for :rear_support_bars, allow_destroy: true
  serialize :types, Array

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
  # types
  # num_layers
  def _num_layers
    open_shelves.count
  end


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

  def bay_size
    "#{back_height}x#{back_width}x#{base_depth}"
  end

  def ref_fixture
    self.fixture_items.select(:fixture_id).group(:fixture_id).count(:fixture_id).keys
  end

  def ref_count
    ref_fixture.count
  end

  # origin: left/bottom corner
  def to_pdf(pdf)
    num_bays = pdf.ostate.fixture[:num_bays]
    case pdf.ostate.fixture[:bay]
    when :side_view
      # draw base, filled with color
      x0 = pdf.ostate.origin[0] + pdf.ostate.options[:bay_left_width]
      y0 = pdf.ostate.origin[1]
      w = base_depth * pdf.ostate.scale
      h = base_height * pdf.ostate.scale
      pdf.fill_color(base_color)
      pdf.fill_and_stroke_rectangle([x0, y0 + h], w, h)

      # draw back
      pdf.fill_color(back_color)
      y1 = pdf.ostate.origin[1] + (base_height + back_height) * pdf.ostate.scale
      pdf.fill_and_stroke_rectangle([x0, y1], back_thick * pdf.ostate.scale, back_height * pdf.ostate.scale)
      pdf.ostate.fixture[:back_left] = x0

      # draw shelves & numbers, filled with color
      pdf.ostate.fixture[:layer] = :side_view
      pdf.ostate.origin[0] = x0 + back_thick * pdf.ostate.scale
      pdf.ostate.origin[1] += (base_height  - layers.first.thick) * pdf.ostate.scale
      layers.each do |layer|
        layer.to_pdf(pdf)
      end
      pdf.ostate.origin[0] = x0 - pdf.ostate.options[:bay_left_width]
      pdf.ostate.origin[1] = y0

    when :front_view
      # move origin to base
      pdf.ostate.origin[1] += base_height * pdf.ostate.scale

      # draw layers, space without fill, shelf with fill
      layers.each do |layer|
        pdf.ostate.fixture[:layer] = :front_view
        layer.to_pdf(pdf)

        # output text of each layer
        pdf.ostate.fixture[:layer] = :text
        layer.to_pdf(pdf)

        if pdf.ostate.fixture[:contains]
          pdf.ostate.fixture[:layer] = pdf.ostate.fixture[:contains]
          layer.to_pdf(pdf)
        end
      end

      # draw base with fill color
      pdf.fill_color(base_color)
      origin = pdf.ostate.origin.dup
      cx = base_width * pdf.ostate.scale
      num_bays.times do
        pdf.fill_and_stroke_rectangle origin, cx, base_height * pdf.ostate.scale
        origin[0] += cx
      end

      # restore origin
      pdf.ostate.origin[1] -= base_height * pdf.ostate.scale
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

  def max_depth
    depths = [base_depth]
    [open_shelves, peg_boards, freezer_chests, rear_support_bars].each do |els|
      els.each do |el|
        depths.push el.depth
      end
    end
    [base_depth, back_thick + depths.max].max
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
