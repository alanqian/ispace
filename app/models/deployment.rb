# add by plan#publish, one deployment by each plan/store
# update by plan_set#download/plan_set#deploy
# no destroy
class Deployment < ActiveRecord::Base
  default_scope -> { where('discarded_at IS NULL') }
  belongs_to :plan_set
  belongs_to :plan
  belongs_to :store

  ##################################
  # for store users
  def download(user_id)
    self.downloaded_by = user_id
    self.download_count += 1
    self.download_1st_at ||= Time.now()
    self.downloaded_at = Time.now()
    self.save
  end

  def deploy(user_id)
    self.deployed_by = user_id
    self.deployed_at = Time.now()
    self.save
  end

  def self.start_download(plan_id, store_id)
    self.where(["discarded_at IS NULL AND plan_id = ? AND store_id = ?", plan_id, store_id]).
      order(published_at: :desc).
      select(:id, :plan_set_name, :downloaded_by, :download_count, :download_1st_at).first
  end

  def self.recent_plans(store_id)
    self.where(["store_id = ? AND discarded_at IS NULL AND deployed_at IS NULL AND downloaded_at IS NULL", store_id]).
      order(to_deploy_at: :desc)
  end

  def self.downloaded_plans(store_id)
    self.where(["store_id = ? AND discarded_at IS NULL AND deployed_at IS NULL AND downloaded_at IS NOT NULL", store_id]).
      order(to_deploy_at: :desc)
  end

  def self.deployed_plans(store_id, count)
    self.where(["store_id = ? AND discarded_at IS NULL AND deployed_at IS NOT NULL", store_id]).
      order(deployed_at: :desc).limit(count)
  end

  ##################################
  # for designers
  def to_plan_deploy
    PlanDeploy.new(plan_id, store_id, store_name, download_1st_at, deployed_at)
  end

  def self.deployed_stores(plan_set_id)
    Deployment.where(["plan_set_id = ? and discarded_at IS NULL and deployed_at IS NOT NULL",
                     plan_set_id]).select(:store_id, :store_name)
  end

  def self.join_stores(plan_set_list)
    Deployment.where(discarded_at: nil).where(plan_set_id: plan_set_list).
      order(:plan_set_id, :deployed_at, :download_1st_at).
      select(:plan_set_id, :plan_id, :store_id, :store_name, :download_1st_at, :deployed_at)
  end

  def self.discard(plan_set_id, user_id)
    self.where(["plan_set_id = ?", plan_set_id]).
      update_all(discarded_at: Time.now, discarded_by: user_id)
  end
end

