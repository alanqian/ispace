json.array!(@plans) do |plan|
  json.extract! plan, :plan_set_id, :category_id, :user_id, :store_id, :num_stores, :fixture_id, :init_facing, :nominal_size, :base_footage, :usage_percent
  json.url plan_url(plan, format: :json)
end
