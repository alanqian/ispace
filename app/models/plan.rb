#encoding: utf-8

class OutputState < Struct.new(:origin, :scale, :options, :fixture, :blocks,
                               :positions, :outline)
  def initialize(hash)
    super(*hash.values_at(:origin, :scale, :options, :fixture, :blocks,
                          :positions))
    self.outline = {}
  end
end

class PlanBlock < Struct.new(:id, :name, :color,
                       :width, :height, :depth,
                       :fixture_item_id, :layer, :seq_num,
                       :width_units, :height_units, :depth_units,
                       :facing, :run, :rank, :leading_gap, :trail_gap,
                       :count, :percentage, :spercent)
  def self.by_attr(product, attr, position)
    pos_params = [
      :fixture_item_id, :layer, :seq_num,
      :width_units, :height_units, :depth_units,
      :facing, :run, :rank].map { |f| position.send(f) }
    params = attr.values_at(:id, :name, :color) .
          concat(product.values_at(:width, :height, :depth)).
          concat(pos_params)
    block = self.new(*params)
    block.height *= position.height_units
    block.depth *= position.depth_units
    block.leading_gap = position.leading_gap + position.leading_divider
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
      :facing, :run, :rank].map { |f| position.send(f) }
    params = product.values_at(:code, # :id
                               :name, :color,
                               :width, :height, :depth).concat(pos_params)
    block = self.new(*params)
    block.leading_gap = position.leading_gap + position.leading_divider
    block.trail_gap = position.trail_divider
    block
  end

  def checker
    "□"
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
        label_font:  '/usr/share/fonts/truetype/ttf-windows/stxihei.ttf',
        left_overflow_text: "<\n<\n<\n<",
        right_overflow_text: ">\n>\n>\n>",
        bay_left_width: 20, # 20pt
        bay_spacing: 8, # 8pt
        distance_above: 10,
        distance_left: 10,
        scale_size: 12,
        scale_font_size: 10,
        mdse_fields: [:seq_num, :id, :name, :facing, :rank, :depth_units, :height_units, :width_units, :checker],
        mdse_fields_name: ["№", "编号", "品名", "排面", "排名", "深", "高", "宽", "☑"],
        summary_field: [:name, :count, :run, :spercent],
        summary_header: ["供应商", "位置", "总排面", "百分比(%)"],
        title: {
          cover: "品类规划",
          toc: "目录",
          blocked_plan: "规划概要图",
          normal_plan: "规划详图",
          fixture: "货架图",
          mdse: "单品排面明细表",
          summary: "商品汇总表",
        },
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

      def pdf.fill_color(color="000000")
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
        remain = (height - scale_font_size * 1.2) / 2
        self.stroke_line [x0, y[0]], [x0, y[0] + remain]
        self.stroke_line [x0, y[1] - remain], [x0, y[1]]

        # draw text
        self.stroke_color("000000")
        self.fill_color("000000")
        self.text_box text,
          at: [x[1] - text_width, y[1]],
          width: text_width,
          height: y[1] - y[0],
          size: scale_font_size,
          align: :right,
          valign: :center
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
        # stroke_axis
      end

      def pdf.header
      end

      def pdf.footer
      end

      def pdf.layout
        return layout
      end

      # register fonts
      pdf.font_families.update(
        "XiHei" => {
          :normal => ostate.options[:label_font],
        },
        "DejaVuSans" => {
          :normal => "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf",
        },
        "Kai" => {
          :normal => "#{Prawn::BASEDIR}/data/fonts/gkai00mp.ttf",
        },
      )
      pdf.fallback_fonts ["Times-Roman", "XiHei", "DejaVuSans"]

      # cover
      make_pdf_cover(pdf, ostate)

      make_pdf_toc(pdf, ostate)

      # blocked plan
      # output fixture-layout: front-view, with shelf numbers
      # output positions blocks grouped by brand
      make_pdf_blocked_plan(pdf, ostate)

      # fixture profile
      # output fixture-layout, with front-view and side-view
      make_pdf_fixture(pdf, ostate)

      # normal plan
      # output fixture-layout: front-view
      # output positions by product
      make_pdf_normal_plan(pdf, ostate)

      # merchandising list
      # output positions by product, and, plan numbers;
      make_pdf_mdse_list(pdf, ostate)

      # summary list
      # statistics info for positions, by suppliers, brands, ...
      # color, supplier, facings, run, run%
      # show tables, and with bar on right side
      make_pdf_summary(pdf, ostate)

      # fill table of content
      make_pdf_outline(pdf, ostate)
    end
  end

  def make_pdf_cover(pdf, ostate)
    # plan_set: name, category, deploy_at
    # plan: created_by, published_at
    #---------------------
    # applying stores:
    # deploy notes:
    pdf.new_page
    ostate.outline[:cover] = pdf.page_count

    pdf.move_down 250
    pdf.text self.plan_set.name,
      :size => 18,
      :align => :center
    pdf.move_down 20
    pdf.text "品类规划书",
      :size => 24,
      :align => :center
    pdf.move_down 6
    pdf.text "(#{self.plan_set.category_name}品类)",
      :size => 18,
      :align => :center

    info = "设计：John Denver\n" +
           "发布：#{self.plan_set.published_at.localtime.to_formatted_s(:db)}\n" +
           "实施：#{self.plan_set.deploy_at.localtime.to_formatted_s(:db)}\n"
    pdf.text_box info,
      :size => 16,
      :at => [150,300],
      :width => 200,
      :height => 80,
      :valign => :center

    # print store_names
    stores_list = Store.where(ref_store_id: self.store_id).select(:name).map { |ar| ar.name }

    pdf.new_page
    pdf.font_size 16
    pdf.text "本次品类规划说明："
    pdf.text self.plan_set.note
    pdf.move_down 20

    pdf.text "本规划书适用于以下门店，请核对后再进行操作"
    pdf.move_down 10
    pdf.text stores_list.join(" ")
    pdf.move_down 10
    pdf.text "具体实施中如发现问题，请联系品类规划专员。"
  end

  def make_pdf_toc(pdf, ostate)
    pdf.new_page
    ostate.outline[:toc] = pdf.page_count
  end

  def make_pdf_blocked_plan(pdf, ostate)
    # output fixtures
    ostate.fixture = {
      output: :front_view_full,
      bay: :front_view,
      contains: :blocks,
    }
    ostate.outline[:blocked_plan] = self.fixture.to_pdf(pdf, ostate)
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
    ostate.outline[:normal_plan] = self.fixture.to_pdf(pdf, ostate)
  end

  def make_pdf_fixture(pdf, ostate)
    ostate.fixture = {
      output: :front_and_side_view,
      bay: :front_view,
      contains: nil,
    }
    ostate.outline[:fixture] = self.fixture.to_pdf(pdf, ostate)
  end

  # merchandising list
  # output positions by product, and, plan numbers;
  def make_pdf_mdse_list(pdf, ostate)
    ostate.fixture = {
      output: :merchandise,
    }
    ostate.outline[:mdse] = self.fixture.to_pdf(pdf, ostate)
  end

  # statistics info for positions, by suppliers, brands, ...
  # color, supplier, facings, run, run%
  # show tables, and with bar on right side
  def make_pdf_summary(pdf, ostate)
    summary = get_summary(:supplier)
    title = ostate.options[:title][:summary]
    fields = ostate.options[:summary_field]
    thead = ostate.options[:summary_header]
    tdata = [thead]
    tdata.concat summary.map { |block| fields.map { |f| block.send(f) } }
    top_percent = summary.first.percentage

    table_ratio = 0.61
    pdf.new_page :landscape
    ostate.outline[:summary] = table_page = pdf.page_count
    pdf.font_size 12
    bbox = pdf.bounds
    # draw title
    pdf.text title
    pdf.move_down 8

    # draw table
    pdf.font_size 10
    table_top = pdf.cursor
    table = pdf.table(tdata,
      width: bbox.right * table_ratio,
      cell_style: { borders: [], },
      header: true) do
        style(rows(0), :borders => [:top, :bottom])
        style(rows(summary.size), :borders => [:top])
      end

    # draw right percentage bar
    pdf.go_to_page(table_page)
    row_heights = table.row_heights
    horz_padding = 10
    vert_padding = 5
    vert_leading = row_heights.shift + vert_padding
    at = [bbox.right * table_ratio, table_top - vert_leading]
    pdf.stroke_color("000000")
    w = bbox.right * (1- table_ratio) - horz_padding * 2
    at[0] += horz_padding
    summary.each do |block|
      h = row_heights.shift
      if block.percentage > 0.0
        if at[1] + vert_padding - h < 0
          table_page += 1
          pdf.go_to_page(table_page)
          at[1] = bbox.top - vert_leading
        end
        pdf.fill_color(block.color)
        pdf.fill_and_stroke_rectangle at, w * block.percentage / top_percent, h - vert_padding * 2
      end
      at[1] -= h
    end
  end

  def make_pdf_outline(pdf, ostate)
    logger.debug "#{ostate.outline.to_s}"
    outline = ostate.outline
    title = ostate.options[:title]
    outline_items = [:cover, :toc, :blocked_plan, :normal_plan, :fixture, :mdse, :summary]
    outline_items.sort! { |a, b| outline[a] <=> outline[b] }

    pdf.outline.define do
      outline_items.each do |f|
        page :title => title[f], :destination => ostate.outline[f]
      end
    end

    if outline[:toc]
      outline_items.reject! { |el| el == :cover || el == :toc }
      pdf.go_to_page(outline[:toc])
      pdf.move_down 100
      pdf.font_size 24
      pdf.text "目录"
      pdf.move_down 20
      pdf.font_size 16
      outline_items.each do |f|
        pdf.text "#{title[f]}  #{outline[f]}"
        pdf.move_down 8
      end
    end

    # number pages
    n = outline_items.find_index(:normal_plan) + 1
    normal_plan_cnt = outline[outline_items[n]] - outline[:normal_plan]

    n = outline_items.find_index(:mdse) + 1
    mdse_cnt = outline[outline_items[n]] - outline[:mdse]

    # number normal plan pages
    string = "- <page>/#{mdse_cnt} -"
    options = {
      :at => [pdf.bounds.right - 150, 0],
      :width => 150,
      :align => :right,
      :page_filter => (outline[:mdse]..outline[:mdse] + mdse_cnt - 1),
      :start_count_at => 1,
      :color => "000000",
      :size => 12,
    }
    pdf.number_pages string, options

    # number normal plan pages
    string = "- <page> -"
    options = {
      :at => [pdf.bounds.right - 150, 0],
      :width => 150,
      :align => :right,
      :page_filter => (outline[:normal_plan]..outline[:normal_plan] + normal_plan_cnt - 1),
      :start_count_at => 1,
      :color => "222222",
      :size => 12,
    }
    pdf.number_pages string, options
  end

  def positions_by_layer
    product_map = Product.on_sales(category_id).to_hash(:id, :code, :name, :color, :width, :height, :depth)
    blocks = {}
    # update position rank
    rank = 1
    positions.sort { |a, b| b.run <=> a.run }.each do |p|
      if p.on_shelf?
        p.rank = rank
        rank += 1
      end
    end

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
        block = PlanBlock.by_attr(product, brand, p)
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

  def get_summary(by = :supplier)
    # by_supplier
    product_map = Product.on_sales(category_id).to_hash(:id, :id, :brand_id, :supplier_id, :width, :height, :depth)
    attr_map = Supplier.where(["category_id=?", category_id]).to_hash(:id, :id, :name, :color)
    attr_id = :supplier_id
    blocks = {}
    total_run = 0
    total_count = 0
    positions.each do |p|
      if p.on_shelf?
        product = product_map[p.product_id]
        attr = attr_map[product[attr_id]]
        block = PlanBlock.by_attr(product, attr, p)
        key = attr[:id]
        total_run += block.run
        total_count += 1
        if blocks[key]
          blocks[key].count += 1
          blocks[key].run += block.run
        else
          block.count = 1
          blocks[key] = block
        end
      end
    end
    blocks.each do |key, block|
      block.percentage = block.run / total_run * 100
    end
    blocks = blocks.values.sort { |a,b| b.percentage <=> a.percentage } .each do |b|
      b.spercent = "%.2f%%" % b.percentage
    end

    # add summary
    sum = PlanBlock.new
    sum.name = ""
    sum.count = total_count
    sum.run = total_run
    sum.percentage = 0
    sum.spercent = "100.0%"
    blocks.push sum
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
