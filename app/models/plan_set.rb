class PlanSet < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  has_many :plans

  attr_accessor :model_stores
  before_save :update_redundancy

  def model_stores
    plans.map { |plan| plan.store_id }
  end

  def model_stores=(stores)
    old_stores = {}.tap { |hash| self.model_stores.each { |id| hash[id.to_s] = 1 } }
    logger.debug "old_stores: #{old_stores.to_s}"
    stores.each do |store_id|
      if !old_stores[store_id] && !store_id.empty?
        self.plans << Plan.create({
          plan_set_id: self.id,
          category_id: self.category_id,
          store_id: store_id,
        })
      end
    end
    logger.debug "add plan, #{stores.to_s} num_stores:#{num_stores} "
  end

  def display_fullname
    "#{name} (#{category_name}), #{created_at.localtime}"
  end

  def display_shortname
    "#{name} (#{category_name})"
  end

  def empty?
    self.plans.empty?
  end

  def any?
    self.plans.any?
  end

  def model_stores_opt
    store_opt_class = Struct.new(:id, :name)
    opt = []
    plans.map do |plan|
      opt.push store_opt_class.new(plan.id, plan.store_name)
    end
    opt
  end

  def update_redundancy
    self.num_plans = plans.count
    self.num_stores = plans.map { |plan| plan.num_stores } .sum
    self.category_name = category.name
  end

  alias_attribute :deploy_at, :published_at
end
