class PlanDeploy < Struct.new(:plan_id, :store_id, :store_name, :downloaded_at, :deployed_at)
end

# select(:plan_set_id, :plan_id, :store_id, :store_name, :download_1st_at, :deployed_at)
