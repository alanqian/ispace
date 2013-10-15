class OutputState < Struct.new(:origin, :scale, :options, :fixture, :blocks,
                               :positions)
  def initialize(hash)
    super(*hash.values_at(:origin, :scale, :options, :fixture, :blocks,
                          :positions))
  end
end

class PlanBlock < Struct.new(:id, :name, :color,
                       :width, :height, :depth,
                       :fixture_item_id, :layer, :seq_num,
                       :width_units, :height_units, :depth_units,
                       :facing, :run, :leading_gap, :trail_gap)
  def self.by_brand(product, brand, position)
    pos_params = [
      :fixture_item_id, :layer, :seq_num,
      :width_units, :height_units, :depth_units,
      :facing, :run, :leading_gap].map { |f| f.to_s }
    params = brand.values_at(:id, :name, :color) .
          concat(product.values_at(:width, :height, :depth)).
          concat(position.attributes.values_at(*pos_params))
    block = self.new(*params)
    block.height *= position.height_units
    block.depth *= position.depth_units
    block.leading_gap += position.leading_divider
    block.trail_gap = position.trail_divider
    block.width = block.width * position.width_units +
      position.middle_divider * (position.width_units - 1) +
      block.leading_gap + block.trail_gap
    block
  end

  def self.by_product(product, position)
    pos_params = [
      :fixture_item_id, :layer, :seq_num,
      :width_units, :height_units, :depth_units,
      :facing, :run, :leading_gap].map { |f| f.to_s }
    params = product.values_at(:code, # :id
                               :name, :color,
                               :width, :height, :depth).
          concat(position.attributes.values_at(*pos_params))
    block = self.new(*params)
    block.leading_gap += position.leading_divider
    block.trail_gap = position.trail_divider
    block
  end
end

class Plan < ActiveRecord::Base
  belongs_to :plan_set
  belongs_to :store
  belongs_to :fixture
  belongs_to :category

  has_many :deployments
  has_many :positions, -> { order("fixture_item_id, layer DESC, seq_num") }
  accepts_nested_attributes_for :positions, allow_destroy: true

  validates :init_facing, numericality: { greater_than_or_equal_to: 1 }
  validates :plan_set_id, presence: true
  validate :can_plan_publish, if: :do_publish?

  before_save :update_redundancy, if: :do_init?
  before_save :do_copy_to, if: :do_copy_to?
  before_save :calc_positions_done, if: :do_layout?

  attr_accessor :new_products


  def verify_fixture?
    StoreFixture.verify_store_fixture?(store_id, category_id)
  end

  def products_changed?
    product_version != Product.version
  end

  def _do
  end

  def _do=(f)
    @did = f.to_sym
  end

  def did
    @did
  end

  def do_init?
    @did.nil?
  end

  def do_copy_to?
    @did == :copy_to
  end

  def do_layout?
    @did == :layout
  end

  def do_publish?
    @did == :publish
  end

  def optional_products
    @products = Product.where({ category_id: category_id })

    # update forced products
    on_shelf = products_on_shelf

    @products.select do |p|
      if !on_shelf[p.code] && p.sale_type == 0
        # update new forced_sale products
        positions << Position.create({
          plan_id: self.id,
          store_id: self.store_id,
          product_id: p.code,
          init_facing: self.init_facing,
          facing: self.init_facing,
        })
      elsif on_shelf[p.code] && p.sale_type == 2
        # update force off shelf products
        pos = positions.where(product_id: p.code).first
        pos.init_facing = 0 if pos
      end
    end

    # optional products updated
    return @products.select do |p|
      !on_shelf[p.code] && p.updated_at.to_i > product_version && p.sale_type == 1
    end
  end

  def copy_product_only
    @copy_product_only
  end

  def copy_product_only=(f)
    logger.debug "copy_options: #{f.to_s}"
    @copy_product_only = (f == "true")
  end

  def target_plans
    @target_plans
  end

  def target_plans=(f)
    logger.debug("set target plan: #{f.to_s}")
    @target_plans = f.reject { |id| id.empty? } .map { |id| id.to_i }
    logger.debug("new target plan: #{@target_plans.to_s}")
  end

  def can_plan_publish
    # TODO:
    logger.debug "check plan finish state"
    true
  end

  def finish_state
    {
      usage_percent: self.usage_percent,
      num_prior_products: self.num_prior_products,
      num_normal_products: self.num_normal_products,
      num_done_priors: self.num_done_priors,
      num_done_normals: self.num_done_normals,
    }
  end

  def do_copy_to
    logger.debug "TODO: do_copy_to, #{@target_plans.to_s}"
  end

  # <LI> element(position): fixture_item, layer; seq_num, product_id
  def fixture_shelf_spaces
    self.fixture.shelf_spaces
  end

  # product_codes: array of string
  def optional_products=(product_codes)
    logger.debug "setup optional products: #{product_codes.to_s}"
    on_shelf = products_on_shelf
    product_codes.reject! { |p| p.empty? }.each do |product_code|
      unless on_shelf[product_code]
        positions << Position.create({
          plan_id: self.id,
          store_id: self.store_id,
          product_id: product_code,
          init_facing: self.init_facing,
          facing: self.init_facing,
        })
      end
    end
    logger.debug "optional products initialized"
    self.update_column(:product_version, Product.version)
  end

  def fixture_id=(fixture_id)
    if fixture_id.kind_of?(Fixnum)
      super
    else
      # create store_fixture
      logger.debug "setup fixture: #{fixture_id.class}, #{fixture_id}"
      StoreFixture.upsert_fixture(store_id, category_id, fixture_id)
    end
  end

  def to_pdf
    pdf_path = Rails.root.join('public', 'downloads', "#{id}.pdf")
    ostate = OutputState.new({
      origin: [0, 0],
      scale: 1.0,
      options: {
        label_font:  '/usr/share/fonts/truetype/fzxh1k.ttf',
        left_overflow_text: "<\n<\n<\n<",
        right_overflow_text: ">\n>\n>\n>",
        bay_left_width: 20, # 20pt
        bay_spacing: 8, # 8pt
        distance_above: 10,
        distance_left: 10,
        scale_size: 12,
        scale_font_size: 10,
      },
      blocks: blocks_by_brand,
      positions: positions_by_layer,
    })
    Prawn::Document.generate(pdf_path,
       page_size: "A4", page_layout: :portrait, skip_page_creation: true) do |pdf|
      # TODO: borrow from prawn master branch, will deleted when prawn released it!
      def pdf.stroke_axis(options = {})
        options = {
          :at => [0,0],
          :height => bounds.height.to_i - (options[:at] || [0,0])[1],
          :width => bounds.width.to_i - (options[:at] || [0,0])[0],
          :step_length => 100,
          :negative_axes_length => 20,
          :color => "000000",
        }.merge(options)

        Prawn.verify_options([:at, :width, :height, :step_length,
                             :negative_axes_length, :color], options)

        save_graphics_state do
          fill_color(options[:color])
          stroke_color(options[:color])

          dash(1, :space => 4)
          stroke_horizontal_line(options[:at][0] - options[:negative_axes_length],
                                 options[:at][0] + options[:width], :at => options[:at][1])
          stroke_vertical_line(options[:at][1] - options[:negative_axes_length],
                               options[:at][1] + options[:height], :at => options[:at][0])
          undash

          fill_circle(options[:at], 1)

          (options[:step_length]..options[:width]).step(options[:step_length]) do |point|
            fill_circle([options[:at][0] + point, options[:at][1]], 1)
            draw_text(point, :at => [options[:at][0] + point - 5, options[:at][1] - 10], :size => 7)
          end

          (options[:step_length]..options[:height]).step(options[:step_length]) do |point|
            fill_circle([options[:at][0], options[:at][1] + point], 1)
            draw_text(point, :at => [options[:at][0] - 17, options[:at][1] + point - 2], :size => 7)
          end
        end
      end

      def pdf.color(color)
        color.sub('#', '')
      end

      def pdf.text_color(color)
        fill_color(color)
      end

      def pdf.fill_color(color)
        super (color || "FFFFFF").sub('#', '')
      end

      def pdf.draw_horz_distance(text, opt)
        at = opt[:at]
        width = opt[:width]
        above = opt[:above]
        scale_size = opt[:scale_size]
        scale_font_size = opt[:scale_font_size]

        # draw vert lines at both side
        x = [at[0], at[0] + width]
        y = [at[1] + above + scale_size / 2, at[1] + above - scale_size / 2]
        self.stroke_line [x[0], y[0]], [x[0], y[1]]
        self.stroke_line [x[1], y[0]], [x[1], y[1]]

        # draw horz arrow line
        y0 = at[1] + above
        text_width = self.width_of(text, size: scale_font_size) + 6
        remain = (width - text_width) / 2
        self.stroke_line [x[0], y0], [x[0] + remain, y0]
        self.stroke_line [x[1] - remain, y0], [x[1], y0]

        # draw scale text
        self.stroke_color("000000")
        self.fill_color("000000")
        self.text_box text,
          at: [x[0], y[0] + (scale_font_size * 1.2 - scale_size) / 2],
          width: width,
          height: scale_size,
          size: scale_font_size,
          align: :center,
          valign: :center
        self.text_box "<",
          at: [x[0], y[0] + (scale_font_size - scale_size) / 2],
          width: width,
          height: scale_size,
          size: scale_font_size,
          align: :left,
          valign: :center
        self.text_box ">",
          at: [x[0], y[0] + (scale_font_size - scale_size) / 2],
          width: width,
          height: scale_size,
          size: scale_font_size,
          align: :right,
          valign: :center
      end

      def pdf.draw_vert_distance(text, opt)
        at = opt[:at]
        height = opt[:height]
        left = opt[:left]
        scale_size = opt[:scale_size]
        scale_font_size = opt[:scale_font_size]

        # draw horz lines at both side
        x = [at[0] - left - scale_size / 2, at[0] - left + scale_size / 2]
        y = [at[1] - height, at[1]]
        self.stroke_line [x[0], y[0]], [x[1], y[0]]
        self.stroke_line [x[0], y[1]], [x[1], y[1]]

        # draw vert arrow line
        x0 = at[0] - left
        text_width = self.width_of(text, size: scale_font_size) + 6
        remain = (height - text_width) / 2
        self.stroke_line [x0, y[0]], [x0, y[0] + remain]
        self.stroke_line [x0, y[1] - remain], [x0, y[1]]

        # draw text
        self.stroke_color("000000")
        self.fill_color("000000")
        self.text_box text,
          at: [x[1] - scale_font_size * 0.25, y[1]],
          width: height,
          height: scale_size,
          size: scale_font_size,
          align: :center,
          valign: :center,
          rotate: 270,
          rotate_around: :upper_left
        self.text_box "<",
          at: [x[1] - scale_font_size * 0.25, y[1]],
          width: height,
          height: scale_size,
          size: scale_font_size,
          align: :left,
          valign: :center,
          rotate: 270,
          rotate_around: :upper_left
        self.text_box ">",
          at: [x[1] - scale_font_size * 0.25, y[1]],
          width: height,
          height: scale_size,
          size: scale_font_size,
          align: :right,
          valign: :center,
          rotate: 270,
          rotate_around: :upper_left
      end

      def pdf.new_page(page_layout = :portrait)
        self.start_new_page(layout: page_layout)
        stroke_axis
      end

      def pdf.header
      end

      def pdf.footer
      end

      def pdf.layout
        return layout
      end

      # cover
      make_pdf_cover(pdf)

      # blocked plan
      # output fixture-layout: front-view, with shelf numbers
      # output positions blocks grouped by brand
      make_pdf_blocked_plan(pdf, ostate)

      # normal plan
      # output fixture-layout: front-view
      # output positions by product
      make_pdf_normal_plan(pdf, ostate)

      # fixture profile
      # output fixture-layout, with front-view and side-view
      make_pdf_fixture(pdf, ostate)

      # merchandising list
      # output positions by product, and, plan numbers;

      # summary list
      # statistics info for positions, by suppliers, brands, ...
      # color, supplier, facings, run, run%
      # show tables, and with bar on right side

      # fill table of content
    end
  end

  def make_pdf_cover(pdf)
    # plan_set: name, category, deploy_at
    # plan: created_by, published_at
    #---------------------
    # applying stores:
    # deploy notes:
    pdf.new_page
    pdf.text "plan cover"
    pdf.text "create date:"
    pdf.text "deploy date:"
    pdf.text "by..."

    # print store_names
    pdf.text "This plan is applied to the following stores:"
    pdf.text "If not, please call: 123456, Mr. Wang"

    pdf.move_down 200
    pdf.text "the following is testing code..."
    bbox = pdf.bounds
    pdf.text "bounds:"
    pdf.text "  left:#{bbox.left}"
    pdf.text "  top:#{bbox.top}"
    pdf.text "  right:#{bbox.right}"
    pdf.text "  bottom:#{bbox.bottom}"
    mbox = pdf.margin_box
    pdf.text "margin_box:"
    pdf.text "  left:#{mbox.left}"
    pdf.text "  top:#{mbox.top}"
    pdf.text "  right:#{mbox.right}"
    pdf.text "  bottom:#{mbox.bottom}"

    # test
    pdf.line [-40, 200], [100, 150]
    pdf.stroke

    pdf.new_page(:landscape)
    pts = [
      [0.0, 256.9079375],
      [60.949625, 256.9079375],
      [60.949625, 83.6826875],
      [0.0,83.6826875]
    ]
    pdf.polygon *pts
    pdf.fill_and_stroke
    pdf.fill_color "FF0000"
    pdf.stroke_polygon [50, 200], [50, 300], [150, 300]
    pdf.fill_polygon [50, 150], [150, 200], [250, 150], [250, 50], [150, 0], [50, 50]

    pdf.dash(4, :space => 8)
    pdf.rectangle [0, 336.9], 660, 27
    pdf.stroke
    pdf.undash

    # pdf.text "this is a landscape page, A4 also"

    # pdf.new_page
    # pdf.text "this is a portrait page, A4 also"
  end

  def make_pdf_blocked_plan(pdf, ostate)
    # output fixtures
    ostate.fixture = {
      output: :front_view_full,
      bay: :front_view,
      contains: :blocks,
    }
    self.fixture.to_pdf(pdf, ostate)
  end

  # normal plan
  # output fixture-layout: front-view
  # output positions by product
  def make_pdf_normal_plan(pdf, ostate)
    ostate.fixture = {
      output: :front_view,
      bay: :front_view,
      contains: :positions,
    }
    self.fixture.to_pdf(pdf, ostate)
  end

  def make_pdf_fixture(pdf, ostate)
    ostate.fixture = {
      output: :front_and_side_view,
      bay: :front_view,
      contains: nil,
    }
    self.fixture.to_pdf(pdf, ostate)
  end


  def positions_by_layer
    product_map = Product.on_sales(category_id).to_hash(:id, :code, :name, :color, :width, :height, :depth)
    blocks = {}
    positions.each do |p|
      if p.on_shelf?
        product = product_map[p.product_id]
        block = PlanBlock.by_product(product, p)
        key = p.layer_key
        blocks[key] ||= []
        blocks[key].push block
      end
    end
    blocks
  end

  def blocks_by_brand
    product_map = Product.on_sales(category_id).to_hash(:id, :id, :brand_id, :width, :height, :depth)
    brand_map = Brand.where(["category_id=?", category_id]).to_hash(:id, :id, :name, :color)
    blocks = {}
    positions.each do |p|
      if p.on_shelf?
        product = product_map[p.product_id]
        brand = brand_map[product[:brand_id]]
        block = PlanBlock.by_brand(product, brand, p)
        key = p.layer_key
        blocks[key] ||= []

        # group by block.id
        last = blocks[key].last
        if last && block.id == last.first.id
          last.push block
        else
          blocks[key].push [block]
        end
      end
    end
    blocks
  end

  def fixture_name
    fixture.nil? ? I18n.t("dict.unset") : fixture.name
  end

  def update_redundancy
    self.fixture_id = 0 #
    sf = StoreFixture.store_fixture(store_id, category_id)
    self.fixture_id = sf.fixture_id if sf
    self.num_stores = Store.where(ref_store_id: self.store_id).count
    self.store_name = self.store.name_with_region
  end

  def empty?
    positions.empty?
  end

  def un_publish
    self.update_column(:published_at, nil)
  end

  def publish
    self.update_column(:published_at, Time.now)
  end

  def finished?
    !published_at.nil?
  end

  def calc_positions_done
    # type, count, done
    # type:
    #   0: "必卖品"
    #   1: "可卖品"
    logger.debug "calc_positions_done"
    occupy_run = {} # (fixture_item_id, layer) => run
    total_count = [0, 0]
    done_count = [0, 0]
    product_map = Product.on_sales(self.category_id).to_hash(:code, :sale_type)
    positions.each do |pos|
      type = product_map[pos.product_id]
      if pos.on_shelf?
        done_count[type] += 1
        occupy_run[pos.layer_key] ||= 0
        occupy_run[pos.layer_key] += pos.run
      end
      total_count[type] += 1
    end

    self.num_prior_products = total_count[0]
    self.num_normal_products = total_count[1]
    self.num_done_priors = done_count[0]
    self.num_done_normals = done_count[1]

    # calculate usage
    run_total = 0
    run_occopies = 0
    merch_space = self.fixture.merch_spaces

    merch_space.each do |k, space|
      run_total += space.merch_width
      if occupy_run[k]
        if occupy_run[k] > space.merch_width # overflow
          run_occopies += space.merch_width
        else
          run_occopies += occupy_run[k]
        end
      end
    end

    self.usage_percent = run_occopies * 100.0 / run_total
    self
  end

  def products_on_shelf
    positions.to_hash(:product_id, :id)
  end

  def init_positions
    self.product_version = Product.version
    dict = positions.to_hash(:product_id, :id)

    # create positions if not exists
    products = Product.on_sales(category_id)
    products.each do |product|
      unless dict[product.code]
        positions << Position.create({
          plan_id: self.id,
          store_id: self.store_id,
          product_id: product.code,
          init_facing: self.init_facing,
          facing: self.init_facing,
        })
      end
    end
  end

  # auto place products
  def auto_position
    merch_space = self.fixture.merch_spaces

    # calculate sorted layer
    gold_point = 150.0
    layers = merch_space.keys.sort do |a, b|
      (merch_space[a].from_base - gold_point).abs <=> (merch_space[b].from_base - gold_point).abs
    end

    # update current places
    self.positions.each do |pos|
      if pos.on_shelf?
        merch_space[pos.layer_key].used_space += pos.run
        if merch_space[pos.layer_key].count < pos.seq_num
          merch_space[pos.layer_key].count = pos.seq_num
        end
      end
    end

    # place force on sale products first, then normal ones
    layer = layers.shift
    product_map = Product.on_sales(self.category_id).to_hash(:code)

    # order position by brand_id
    self.positions.sort! do |a, b|
      prod_a = product_map[a.product_id]
      prod_b = product_map[b.product_id]
      prod_a.brand_id <=> prod_b.brand_id
    end

    0.upto(1) do |sale_type|
      self.positions.map! do |pos|
        prod = product_map[pos.product_id]
        if !pos.on_shelf? && prod.sale_type == sale_type
          run = pos.init_facing * prod.width
          while layer && merch_space[layer].used_space + run > merch_space[layer].merch_width
            layer = layers.shift
          end
          if layer && merch_space[layer].used_space + run <= merch_space[layer].merch_width
            pos.fixture_item_id = merch_space[layer].fixture_item
            pos.layer = merch_space[layer].layer
            pos.seq_num = merch_space[layer].count + 1
            pos.run = run
            pos.facing = pos.width_units = pos.init_facing
            pos.height_units = (merch_space[layer].merch_height / prod.height).floor
            pos.depth_units = (merch_space[layer].merch_depth / prod.depth).floor
            pos.units = pos.depth_units * pos.width_units * pos.height_units
            merch_space[layer].count += 1
            merch_space[layer].used_space += run
          end
        end
        pos
      end
    end
    calc_positions_done
    self.save
  end
end
