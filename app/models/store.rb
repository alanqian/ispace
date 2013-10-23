class Store < ActiveRecord::Base
  scope :model_store, -> { where('ref_store_id = id') }

  before_save :update_region_name

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

  def update_region_name
    self.region_name = Region.get_display_name(region_id)
  end

  def name_with_region
    "#{region_name} #{name}"
  end
end

