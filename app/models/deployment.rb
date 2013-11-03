# add by plan#publish, one deployment by each plan/store
# update by plan_set#download/plan_set#deploy
# no destroy
class Deployment < ActiveRecord::Base
  belongs_to :plan_set
  belongs_to :plan
  belongs_to :store

  def download(user_id)
    self.downloaded_by = user_id
    self.download_count += 1
    self.first_downloaded_at ||= Time.now()
    self.download_at = Time.now()
    self.save
  end

  def deploy(user_id)
    self.deployed_by = user_id
    self.deployed_at = Time.now()
    self.save
  end

  def self.deployed_stores(plan_set_id)
    Deployment.where(["plan_set_id = ? and discarded_at IS NULL and deployed_at IS NOT NULL",
                     plan_set_id]).select(:id, :store_id)
  end

  def self.undeployed_stores(plan_set_id)
    Deployment.where(["plan_set_id = ? and discarded_at IS NULL and deployed_at IS NULL",
                     plan_set_id]).select(:id, :store_id, :download_1st_at)
  end

  def self.downloaded_count(plan_set_id)
    self.where(["plan_set_id = ? AND downloaded_at IS NOT NULL", plan_set_id]).count
  end

  def self.deployed_store_count(plan_set_id)
    self.where(["plan_set_id = ? AND deployed_at IS NOT NULL", plan_set_id]).count
  end

  def self.recent_plans(store_id)
    self.where(["store_id = ? AND deployed_at IS NULL", store_id]).order(to_deploy_at: :desc)
  end

  def self.deployed_plans(store_id)
    self.where(["store_id = ? AND deployed_at IS NOT NULL", store_id]).order(deployed_at: :desc)
  end
end

