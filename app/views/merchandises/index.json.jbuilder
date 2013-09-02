json.array!(@merchandises) do |merchandise|
  json.extract! merchandise, :product_id, :store_id, :user_id, :supplier_id, :price, :new_product, :on_promotion, :force_on_shelf, :forbid_on_shelf, :max_facing, :min_facing, :rcmd_facing, :volume, :vulume_rank, :value, :value_rank, :profit, :profit_rank, :psi, :psi_rank
  json.url merchandise_url(merchandise, format: :json)
end