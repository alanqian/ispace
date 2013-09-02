json.array!(@manufacturers) do |manufacturer|
  json.extract! manufacturer, :name, :category_id, :desc, :color
  json.url manufacturer_url(manufacturer, format: :json)
end