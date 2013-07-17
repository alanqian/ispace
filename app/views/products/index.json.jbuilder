json.array!(@products) do |product|
  json.extract! product, :category_id, :brand_id, :mfr_id, :user_id, :id, :name, :height, :width, :depth, :weight, :price_level, :size_name, :case_pack_name, :bar_code, :color
  json.url product_url(product, format: :json)
end