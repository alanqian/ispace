json.array!(@regions) do |region|
  json.extract! region, :id, :name, :desc
  json.url region_url(region, format: :json)
end