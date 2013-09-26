class Plan < ActiveRecord::Base
  belongs_to :plan_set
  belongs_to :store
  belongs_to :fixture
  belongs_to :category

  has_many :deployments
  has_many :positions
  accepts_nested_attributes_for :positions, allow_destroy: true

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
      if pos.done?
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
    products = products_on_sale
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
      if pos.done?
        merch_space[pos.layer_key].used_space += pos.run
        if merch_space[pos.layer_key].count < pos.seq_num
          merch_space[pos.layer_key].count = pos.seq_num
        end
      end
    end

    # place force on sale products first, then normal ones
    layer = layers.shift
    product_map = Product.on_sales(self.category_id).to_hash(:code)
    new_positions = []
    0.upto(1) do |sale_type|
      self.positions.map! do |pos|
        prod = product_map[pos.product_id]
        if !pos.done? && prod.sale_type == sale_type
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
