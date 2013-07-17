json.array!(@suppliers) do |supplier|
  json.extract! supplier, :name, :category_id, :desc, :color
  json.url supplier_url(supplier, format: :json)
end