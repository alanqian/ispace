class Store < ActiveRecord::Base
  before_save :update_redundancy

  def self.define_model_store(stores)
    if stores.empty?
      logger.warn "cannot define model_store for null"
    else
      # update_all: ref_store_id = stores.first
      # update_first: refer_count = stores.count
      self.where({id: stores}).update_all(ref_store_id: stores.first)
      self.find(stores.first).update_column(refer_count: stores.count)
    end
  end

  def self.model_stores
    self.where("ref_store_id = id")
  end

  def self.model_store_options
    self.where("ref_store_id = id").select([:id, :name])
  end

  def update_redundancy
    self.region_name = Region.get_display_name(region_id)
    self.pinyin = HanziToPinyin.hanzi_to_pinyin(name)
  end

  def name_with_region
    "#{region_name} #{name}"
  end
end

