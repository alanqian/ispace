class Store < ActiveRecord::Base
  scope :model_store, -> { where('ref_store_id = id') }
  default_scope -> { where('deleted_at is NULL') }

  has_one :region

  before_save :update_region_name

  has_many :sales, class_name: 'users', foreign_key: 'store_id'
  has_many :store_fixtures
  accepts_nested_attributes_for :store_fixtures, allow_destroy: true

  def image_file=(upload_file)
    # super(upload_file.original_filename)
    # logger.debug "upload_file image_file, file:#{image_file}"
    ext = File.extname(File.basename(upload_file.original_filename).downcase)
    filename = "#{id}#{ext}"
    File.open("#{Rails.root}/public/store_images/#{filename}", "wb") do |f|
      f.write(upload_file.read)
    end
    super(filename)
  end

  def self.define_model_store(stores)
    if stores.empty?
      logger.warn "cannot define model_store for null"
    else
      # update_all: ref_store_id = stores.first
      # update_first: refer_count = stores.count
      self.where({id: stores}).update_all(ref_store_id: stores.first)
      self.find(stores.first).update_column(:ref_count, stores.count)
    end
  end

  def self.setup_model_store(commit, stores_param, ref_store_id)
    case commit
    when :set_model_store
      # verify ref_store_id is valid model store
      logger.debug "verify ref_store_id"
      that = self.find(ref_store_id)
      return false if that.ref_store_id != that.id

      # store ref_store_id, is a model_store at first
      logger.debug "filter stores, stores:#{stores_param.to_json}"
      # choose stores which is NOT TRUE model store itself and not ref to THAT
      stores = self.where(id: stores_param).
        where(["ref_store_id IS NULL OR ref_store_id != ?", ref_store_id]).
        where(["ref_store_id IS NULL OR ref_store_id != id OR ref_count = 1"]).
        select(:id, :ref_store_id)

      # decrement ref_count for ref store
      logger.debug "dec ref_count, stores:#{stores.to_json}"
      stores.each do |store|
        self.decrement_counter(:ref_count, store.ref_store_id) if store.ref_store_id
      end

      # set ref_store
      logger.debug "set ref_store_id, stores:#{stores.to_json}"
      list = stores.map { |store| store.id }
      self.where(id: list).update_all(ref_store_id: ref_store_id)

      # set ref_count of new ref_store
      logger.debug "inc ref_count"
      that.update_column(:ref_count, that.ref_count + stores.size)
      return true

    when :set_as_model_store
      stores = self.where(["ref_store_id IS NULL OR ref_store_id != id"]).where(id: stores_param).select(:id, :ref_store_id)
      logger.info "modify stores as model_store, #{stores.to_json}"
      stores.each do |store|
        # dec ref_count of refer_to
        self.decrement_counter(:ref_count, store.ref_store_id) if store.ref_store_id
        # set self
        store.update_columns(ref_store_id: store.id, ref_count: 1)
      end
      true
    else
      false
    end
  rescue => e
    logger.warn "setup_model_store failed, e:#{e.to_s}"
    false
  end

  def self.model_stores
    self.where("ref_store_id = id")
  end

  def self.model_store_options
    self.where("ref_store_id = id").select([:id, :name])
  end

  def follow_stores
    self.class.where("ref_store_id = ?", id)
  end

  def self.follow_store_map(store_id_list)
    self.where(ref_store_id: store_id_list).
      select(:id, :name, :ref_store_id).to_hash2(:ref_store_id, :id, :name)
  end

  def rebuild_all_fixtures
    self.store_fixtures.clear
    prev_parent_id = nil
    Category.nodes.each do |category|
      sf = StoreFixture.new(store_id: self.id, category_id: category.id)
      if prev_parent_id != category.parent_id
        sf.show_up_dir = true
      else
        sf.show_up_dir = false
      end
      self.store_fixtures << sf
      prev_parent_id = category.parent_id
    end
  end

  def update_redundancy
    self.region_name = Region.get_display_name(region_id)
    self.pinyin = HanziToPinyin.hanzi_to_pinyin(name)
  end

  def name_with_region
    "#{region_name} #{name}"
  end

  private
  def update_region_name
    region = Region.find(self.region_id)
    self.region_name = region.name
  rescue
  end
end

