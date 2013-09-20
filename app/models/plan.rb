class Plan < ActiveRecord::Base
  belongs_to :plan_set
  belongs_to :store
  belongs_to :fixture
  belongs_to :category

  has_many :deployments
  has_many :positions

  validates :plan_set_id, presence: true

  before_save :update_redundancy

  attr_accessor :new_products

  def verify_fixture?
    StoreFixture.verify_store_fixture?(store_id, category_id)
  end

  def products_changed?
    product_version != Product.version
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
end

