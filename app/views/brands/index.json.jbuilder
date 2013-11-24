json.array!(@brands) do |brand|
  json.extract! brand, :name, :category_id, :color
  json.url brand_url(brand, format: :json)
end