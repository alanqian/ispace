json.array!(@sales) do |sale|
  json.extract! sale, :product_id, :store_id, :num_stores, :user_id, :import_id, :price, :facing, :run, :volume, :volume_rank, :value, :value_rank, :margin, :margin_rank, :psi, :psi_rank, :psi_rule_id, :rcmd_facing, :detail, :started_at, :ended_at
  json.url sale_url(sale, format: :json)
end