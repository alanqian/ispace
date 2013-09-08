json.array!(@merchandises) do |merchandise|
  json.extract! merchandise, :product_id, :store_id, :user_id, :price, :facing, :run, :volume, :volume_rank, :value, :value_rank, :margin, :margin_rank, :psi, :psi_rank, :psi_by
  json.url merchandise_url(merchandise, format: :json)
end