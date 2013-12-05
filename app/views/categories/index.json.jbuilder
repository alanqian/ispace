json.array!(@categories) do |category|
  json.extract! category, :code, :name, :parent_id, :memo
  json.url category_url(category, format: :json)
end
