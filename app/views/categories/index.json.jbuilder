json.array!(@categories) do |category|
  json.extract! category, :id, :desc
  json.url category_url(category, format: :json)
end