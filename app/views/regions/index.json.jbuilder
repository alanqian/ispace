json.array!(@regions) do |region|
  json.extract! region, :code, :name, :consume_type, :memo
  json.url region_url(region, format: :json)
end
