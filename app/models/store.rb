class Store < ActiveRecord::Base
  scope :model_store, -> { where('ref_store_id = id') }

  has_one :region

  before_save :update_region_name


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

