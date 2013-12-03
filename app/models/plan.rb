#encoding: utf-8

class Plan < ActiveRecord::Base
  include PdfExtension
  include ActiveModel::Dirty

  serialize :parts, Array

  belongs_to :user
  belongs_to :plan_set
  belongs_to :store
  belongs_to :fixture
  belongs_to :category

  has_many :deployments
  has_many :positions,  -> { order("fixture_item_id, layer DESC, seq_num") }, dependent: :destroy, autosave: true
  accepts_nested_attributes_for :positions, allow_destroy: true

  validates :init_facing, numericality: { greater_than_or_equal_to: 1 }
  validates :plan_set_id, presence: true

  before_save :update_redundancy, if: "did.nil?"

  before_save :do_copy_to, if: "did == :copy_to"
  before_save :calc_positions_done, if: "did == :layout"
  before_save :update_products, if: :init_facing_changed?
  after_save :clear_stale_position, if: "did == :layout"
  after_save :update_plan_set

  def verify_fixture?
    StoreFixture.verify_store_fixture?(store_id, category_id)
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

  def plan_set_name
    self.plan_set.name
  end

  def category_name
    self.category.nil? ? "" : self.category.name
  end

  def status_s
    # opened status
    st = "#{usage_percent}%"
    if self.num_prior_products != self.num_done_priors
      st += ",-#{self.num_prior_products - self.num_done_priors}"
    end
  end

  def status
    return :new if positions.empty?
    return :opened
  end

  def can_be_closed?
    return false if self.num_prior_products != self.num_done_priors
    return true if self.usage_percent >= 90.0
    return true if self.num_done_normals >= self.num_normal_products * 9 / 10
    false
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

  # dup to another plan_set with same category
  def deep_copy(plan_set)
    return nil if plan_set.category_id != self.category_id || plan_set.id == self.plan_set_id
    plan = self.dup
    plan.plan_set_id = plan_set.id
    plan.save!

    # dup positions, same store, same fixture, only different plan_id
    plan.positions = self.positions.map { |position| position.dup }
    plan.unpublish
    plan.save!
    plan
  end

  def do_copy_to
    logger.debug "TODO: do_copy_to, #{@target_plans.to_s}"
  end

  # <LI> element(position): fixture_item, layer; seq_num, product_id
  def fixture_shelf_spaces
    self.fixture.shelf_spaces
  end

  def on_shelves
    Product.under(self.category_id).on_shelf(self.min_product_grade)
  end

  def update_init_facing
    if init_facing_changed?
      self.positions.not_on_shelf.update_all(init_facing: self.init_facing)
    end
  end

  # update products if necessary
  def update_products
    return if !min_product_grade_changed? && product_version == Product.version
    logger.info "update_products, plan:#{id} min_product_grade:#{min_product_grade}, category:#{category_id}"

    # get products can on shelf
    products = on_shelves.select(:code).order(:code).map { |p| p.code }
    # remove unused positions: mark and sweep
    marked = self.positions.select([:id, :product_id]).order(:product_id).to_a
    staled = []

    pcode = products.shift
    pos = marked.shift
    while pcode != nil
      while pos != nil && pos.product_id < pcode
        # staled product
        staled.push pos
        pos = marked.shift
      end

      if pos.nil? || pcode < pos.product_id
        # pocde not equal, new product
        positions << Position.create({
          plan_id: self.id,
          store_id: self.store_id,
          product_id: pcode,
          init_facing: self.init_facing,
          facing: self.init_facing,
          leading_gap: 0.0,
          leading_divider: 0.0,
          middle_divider: 0.0,
          trail_divider: 0.0,
        })
      else
        # equal pcode, next position
        while pos != nil && pos.product_id == pcode
          pos = marked.shift
        end
      end

      # next product
      pcode = products.shift
    end

    # delete unselected products
    staled.concat(marked)
    if staled.any?
      self.positions.delete(staled)
    end

    logger.debug "plan products initialized"
    if self.positions.any?
      self.update_column(:product_version, Product.version)
    end
    self.save!
  end

  # TODO: fixture_version
  def fixture_id=(fixture_id)
    unless fixture_id.kind_of?(Fixnum)
      # create store_fixture
      logger.info "create store_fixture, fixture:#{fixture_id} store_id:#{store_id} category_id:#{category_id}"
      StoreFixture.upsert_fixture(store_id, category_id, fixture_id)
    end
    super(fixture_id)
  end

  def positions_by_layer
    product_map = on_shelves.select(:code, :name, :color, :width, :height, :depth)
      .to_hash(:id, :code, :name, :color, :width, :height, :depth)
    blocks = {}
    # update position rank
    rank = 1
    positions.select { |p| p.on_shelf? }.sort { |a, b| b.run <=> a.run }.each do |p|
      p.rank = rank
      rank += 1
    end

    positions.each do |p|
      if p.on_shelf?
        product = product_map[p.product_id]
        block = PlanBlock.by_product(product, p)
        key = p.layer_key
        blocks[key] ||= []
        blocks[key].push block
      else
        p.rank = rank
      end
    end
    blocks
  end

  def blocks_by_brand
    product_map = on_shelves.select(:code, :name, :brand_id, :color, :width, :height, :depth)
      .to_hash(:id, :id, :brand_id, :width, :height, :depth)
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
    product_map = on_shelves.select(:code, :brand_id, :supplier_id, :width, :height, :depth)
      .to_hash(:id, :id, :brand_id, :supplier_id, :width, :height, :depth)

    attr_id = "#{by}_id".to_sym
    attr_klass = by.to_s.classify.constantize
    attr_map = attr_klass.where(["category_id=?", category_id]).to_hash(:id, :id, :name, :color)

    blocks = {}
    total_run = 0
    total_count = 0
    positions.each do |p|
      if p.on_shelf?
        product = product_map[p.product_id]
        attr = attr_map[product[attr_id]]
        if attr != nil
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
    if self.fixture_id.nil?
      sf = StoreFixture.store_fixture(store_id, category_id)
      self.fixture_id = sf ? sf.fixture_id : 0
    end
    self.num_stores = Store.where(ref_store_id: self.store_id).count
    self.store_name = self.store.name_with_region
  end

  def update_plan_set
    self.plan_set.update_recent_plan(self)
    # TODO: if plan_set publised, re-generate pdf of this plan
    # or: cannot edit closed plan?
  end

  def empty?
    positions.empty?
  end

  def clear_stale_position
    #logger.debug "clear_stale_position"
    self.positions.where(["version < ?", self.version]).delete_all()
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
    product_map = on_shelves.select(:code, :grade).to_hash(:code, :grade)
    # add two dict to detect positions on different layers
    done_dict = {}
    total_dict = {}
    positions.each do |pos|
      prod_type = product_map[pos.product_id]
      index = prod_type == 'A' ? 0 : 1
      if pos.on_shelf? && !done_dict.key?(pos.product_id)
        done_count[index] += 1
        occupy_run[pos.layer_key] ||= 0
        occupy_run[pos.layer_key] += pos.run
        done_dict[pos.product_id] = 1
      end
      if !total_dict.key?(pos.product_id)
        total_count[index] += 1
        total_dict[pos.product_id] = 1
      end
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
    product_map = on_shelves.select(:code, :grade, :width, :height, :depth)
      .to_hash(:code)

    # order position by brand_id
    self.positions.sort! do |a, b|
      prod_a = product_map[a.product_id]
      prod_b = product_map[b.product_id]
      prod_a.brand_id <=> prod_b.brand_id
    end

    "A".upto(self.min_product_grade) do |grade|
      self.positions.map! do |pos|
        prod = product_map[pos.product_id]
        if !pos.on_shelf? && prod.grade == grade
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

  def full_name
    "#{plan_set.full_name}-#{store_name}"
  end

  def name_with_summary
    if self.usage_percent.nil?
      "#{self.store.name}(0%)"
    else
      "#{self.store.name}(#{sprintf("%.1f%%", self.usage_percent)})"
    end
  end

  def self.recent_edited(count = 8)
    self.select(:id, :plan_set_id, :store_id, :store_name, :updated_at,
               :num_prior_products, :num_normal_products, :num_done_priors,
               :num_done_normals, :usage_percent, :num_stores).
               order(updated_at: :desc).limit(count)
  end

  def init_deployment
    self.store.follow_stores.each do |st|
      Deployment.create(plan_id: self.id,
                        plan_set_id: self.plan_set.id,
                        plan_set_name: self.plan_set.full_name,
                        plan_set_note: self.plan_set.note,
                        store_id: st.id,
                        store_name: st.name,
                        published_at: Time.now,
                        to_deploy_at: self.plan_set.to_deploy_at)
    end
  end

  #########################################################################
  # export to pdf
  def plan_pdf
    pdf_path = Rails.root.join('public', 'downloads', "#{id}.pdf")
  end

  def remove_pdf
    FileUtils.rm plan_pdf, :force => true # never raise exception
  end

  def publish
    if self.to_pdf
      init_deployment
    end
  rescue Exception => e
    logger.warn "failed in to_pdf, e: #{e}, #{e.backtrace}"
  end

  def to_pdf
    # check plan status
    if self.plan_set.published_at.nil?
      logger.warn "failed to output pdf because plan_set has not been published, plan:#{id}"
      return
    end
    _to_pdf
  end

  def _to_pdf
    ostate = OutputState.new({
      origin: [0, 0],
      scale: 1.0,
      options: APP_CONFIG["pdf_options"],
      blocks: blocks_by_brand,
      positions: positions_by_layer,
    })

    Prawn::Document.generate(plan_pdf,
      page_size: "A4", page_layout: :portrait, skip_page_creation: true) do |pdf|

      pdf.ostate = ostate
      pdf.register_fonts(APP_CONFIG["pdf_fonts"])

      # cover
      make_pdf_cover(pdf)

      make_pdf_toc(pdf)

      # blocked plan
      # output fixture-layout: front-view, with shelf numbers
      # output positions blocks grouped by brand
      make_pdf_blocked_plan(pdf)

      # fixture profile
      # output fixture-layout, with front-view and side-view
      make_pdf_fixture(pdf)

      # normal plan
      # output fixture-layout: front-view
      # output positions by product
      make_pdf_normal_plan(pdf)

      # merchandising list
      # output positions by product, and, plan numbers;
      make_pdf_mdse_list(pdf)

      # summary list
      # statistics info for positions, by suppliers, brands, ...
      # color, supplier, facings, run, run%
      # show tables, and with bar on right side
      make_pdf_summary(pdf)

      # fill table of content
      make_pdf_outline(pdf)
    end
    true
  end

  def make_pdf_cover(pdf)
    # plan_set: name, category, to_deploy_at
    # plan: created_by, published_at
    #---------------------
    # applying stores:
    # deploy notes:
    pdf.new_page
    pdf.ostate.outline[:cover] = pdf.page_count

    pdf.move_down 250
    pdf.font pdf.ostate.options[:label_font]
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

    published_at = self.plan_set.published_at != nil ?
      self.plan_set.published_at.localtime.to_formatted_s(:db) : ""
    to_deploy_at = self.plan_set.to_deploy_at != nil ?
      self.plan_set.to_deploy_at.to_formatted_s(:db) : ""
    info = "设计：John Denver\n" +
           "发布：#{published_at}\n" +
           "实施：#{to_deploy_at}\n"
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

  def make_pdf_toc(pdf)
    pdf.new_page
    pdf.ostate.outline[:toc] = pdf.page_count
  end

  def make_pdf_blocked_plan(pdf)
    # output fixtures
    pdf.ostate.fixture = {
      output: :front_view_full,
      bay: :front_view,
      contains: :blocks,
    }
    pdf.ostate.outline[:blocked_plan] = self.fixture.to_pdf(pdf)
  end

  # normal plan
  # output fixture-layout: front-view
  # output positions by product
  def make_pdf_normal_plan(pdf)
    pdf.ostate.fixture = {
      output: :front_view,
      bay: :front_view,
      contains: :positions,
    }
    pdf.ostate.outline[:normal_plan] = self.fixture.to_pdf(pdf)
  end

  def make_pdf_fixture(pdf)
    pdf.ostate.fixture = {
      output: :front_and_side_view,
      bay: :front_view,
      contains: nil,
    }
    pdf.ostate.outline[:fixture] = self.fixture.to_pdf(pdf)
  end

  # merchandising list
  # output positions by product, and, plan numbers;
  def make_pdf_mdse_list(pdf)
    pdf.ostate.fixture = {
      output: :merchandise,
    }
    pdf.ostate.outline[:mdse] = self.fixture.to_pdf(pdf)
  end

  # statistics info for positions, by suppliers, brands, ...
  # color, supplier, facings, run, run%
  # show tables, and with bar on right side
  def make_pdf_summary(pdf)
    summary_by = pdf.ostate.options[:summary_by]
    summary = get_summary(summary_by)
    title = pdf.ostate.options[:title][:summary]
    fields = pdf.ostate.options[:summary_field]
    thead = pdf.ostate.options[:summary_header]
    thead[0] = pdf.ostate.options[:summary_names][summary_by]
    tdata = [thead]
    tdata.concat summary.map { |block| fields.map { |f| block.send(f) } }
    top_percent = summary.first.percentage

    table_ratio = 0.61
    pdf.new_page :landscape
    pdf.ostate.outline[:summary] = table_page = pdf.page_count
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

  def make_pdf_outline(pdf)
    logger.debug "output pdf_outline, #{pdf.ostate.outline.to_s}"
    outline = pdf.ostate.outline
    title = pdf.ostate.options[:title]
    outline_items = [:cover, :toc, :blocked_plan, :normal_plan, :fixture, :mdse, :summary]
    outline_items.sort! { |a, b| outline[a] <=> outline[b] }

    pdf.outline.define do
      outline_items.each do |f|
        page :title => title[f], :destination => pdf.ostate.outline[f]
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
end
