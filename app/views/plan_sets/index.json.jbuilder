json.array!(@plan_sets) do |plan_set|
  json.extract! plan_set, :name, :notes, :category_id, :user_id, :plans, :stores, :published_at, :unpublished_plans, :undeployed_stores
  json.url plan_set_url(plan_set, format: :json)
end