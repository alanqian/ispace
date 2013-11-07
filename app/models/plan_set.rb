class PlanSet < ActiveRecord::Base
  serialize :recent_plans, Array
  belongs_to :category
  belongs_to :user
  has_many :plans, dependent: :destroy

  attr_accessor :model_stores
  before_save :update_redundancy

  def model_stores
    plans.map { |plan| plan.store_id }
  end

  def category_id=(category_id)
    if plans.any?
      logger.warn "failed to modify category since there are plans in plan_set, category_id:#{category_id}"
    else
      super(category_id)
    end
  end

  # initialize store plans
  def model_stores=(stores)
    old_stores = {}.tap { |hash| self.plans.each { |plan| hash[plan.store_id.to_s] = plan } }
    logger.debug "old_stores: #{old_stores.to_s}"

    stores.each do |store_id|
      next if store_id.empty?

      if !old_stores[store_id]
        # create new plan for model store
        self.plans << Plan.create({
          plan_set_id: self.id,
          category_id: self.category_id,
          store_id: store_id,
        })
      else
        old_stores.delete(store_id)
      end
    end
    #
    if old_stores.any?
      self.plans.delete(old_stores.values)
      logger.debug "remove old_stores: #{old_stores.values.to_s}"
    end
    logger.debug "updated plan_set model stores, #{stores.to_s} num_stores:#{num_stores} "
  end

  def full_name
    "#{name}(#{category_name})"
  end

  def empty?
    self.plans.empty?
  end

  def any?
    self.plans.any?
  end

  def model_stores_opt
    opt = []
    plans.map do |plan|
      opt.push Option.new(plan.id, plan.store_name)
    end
    opt
  end

  def num_deployed_stores
    num_stores - undeployed_stores
  end

  def deployed_stores
    Deployment.deployed_stores(self.id)
  end

  def update_redundancy
    self.category_name = category.name
    self.num_plans = plans.count
    self.num_stores = plans.map { |plan| plan.num_stores } .sum
    self.undeployed_stores = self.num_stores - self.deployed_stores.count
  end

  # dup plan_set to another category: name,category_id,to_deploy_at, model_stores
  def dup_to(ctg_id)
    return nil if ctg_id == self.category_id

    plan_set = self.dup
    plan_set.category_id = ctg_id
    plan_set.to_deploy_at = Date.today if plan_set.to_deploy_at < Date.today
    plan_set.save!

    self.plans.each do |plan|
      plan_set.plans << Plan.create({
        plan_set_id: plan_set.id,
        category_id: plan_set.category_id,
        store_id: plan.store_id,
      })
    end
    plan_set.unpublish
    plan_set.save!
    plan_set
  end

  # dup whole plan_set, same category but a different name:
  # plans, positions, ...
  def deep_copy(plan_set_name)
    return nil if plan_set_name.strip! == self.name
    plan_set = self.dup
    plan_set.name = plan_set_name
    plan_set.to_deploy_at = Date.today if plan_set.to_deploy_at < Date.today
    plan_set.save!

    # dup all plans
    plan_set.plans = self.plans.map { |plan| plan.deep_copy(plan_set) }
    plan_set.unpublish
    plan_set.save!
    plan_set
  end

  def publish(publish_on, user_id)
    if publish_on
      if plans.empty?
        logger.debug "cannot publish empty plan_set, plan_set:#{self.id}"
        return false
      end
      if plans.select { |plan| plan.empty? }.any?
        logger.debug "cannot publish plan_set with empty plans, plan_set:#{self.id}"
        return false
      end

      self.update_column(:published_at, Time.now)
      self.plans.each { |plan| plan.delay.publish }
      logger.debug "plan_set published, plan_set:#{self.id}"
      return true
    else
      logger.debug "unpublish plan_set, plan_set:#{self.id}"
      self.update_column(:published_at, nil)
      # update deployments
      Deployment.discard(self.id, user_id)
      # remove pdfs of plans
      self.plans.each { |plan| plan.remove_pdf }
    end
  end

  def update_recent_plan(plan)
    logger.debug "update_recent_plan, plan_set:#{id} plan_id:#{plan.id} name:#{plan.name_with_summary} recent_plans:#{recent_plans.to_json}"
    self.recent_plans.delete_if { |p| p.id == plan.id }
    self.recent_plans.unshift(Option.new(plan.id, plan.name_with_summary))
    self.recent_plans = self.recent_plans[0..15]
    logger.debug "recent_plans updated, plan_set:#{id} recent_plans:#{self.recent_plans.to_json}"
    self.save!
  end

  def self.designing_sets
    self.where("num_plans = 0 OR published_at IS NULL").order('created_at DESC')
  end

  def self.deploying_sets
    plan_sets = self.where("num_plans > 0 AND published_at IS NOT NULL AND undeployed_stores > 0").
      order('published_at DESC').select(:id, :name, :category_name, :published_at, :to_deploy_at)
    deployings = []
    if plan_sets.any?
      plan_set_list = plan_sets.map { |ps| ps.id }
      deploys = Deployment.join_stores(plan_set_list)
      plan_sets.each do |plan_set|
        count = 0
        deployeds = []
        downloads = []
        nones = []
        deploys.select { |dp| dp.plan_set_id = plan_set.id }.each do |d|
          pd = d.to_plan_deploy
          if pd.deployed_at != nil
            deployeds.push pd
          elsif pd.downloaded_at.nil?
            nones.push pd
          else
            downloads.push pd
          end
          count += 1
        end
        deployings.push({
          plan_set: plan_set,
          deployed: deployeds,
          none: nones,
          download: downloads,
          count: count,
        })
      end
    end
    return deployings
  end

  def self.deployed_sets(count)
    # published date, download date range, deploy date range
    plan_sets = self.where("num_plans > 0 AND undeployed_stores = 0").
      order(to_deploy_at: :desc).limit(count)
    deployeds = []
    if plan_sets.any?
      plan_set_list = plan_sets.map { |ps| ps.id }
      deploys = Deployment.join_stores(plan_set_list)
      plan_sets.each do |plan_set|
        count = 0
        deployeds = []
        downloads = []
        nones = []
        this_deploys = deploys.select { |dp| dp.plan_set_id = plan_set.id }
        download_1st, download_last = this_deploys.
          minmax { |a, b| a.download_1st_at <=> b.download_1st_at }
        deploy_1st, deploy_last = this_deploys.
          minmax { |a, b| a.deployed_at <=> b.deployed_at }

        download_1st = (download_1st - plan_set.published_at).to_i
        download_last = (download_last - plan_set.published_at).to_i
        deploy_1st = (deploy_1st - plan_set.published_at).to_i
        deploy_last = (deploy_last - plan_set.published_at).to_i
        deployeds.push({
          plan_set: plan_set,
          download_1st: download_1st,
          download_last: download_last,
          deploy_1st: deploy_1st,
          deploy_last: deploy_last,
        })
      end
    end
    return deployeds
  end
end
