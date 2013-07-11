json.array!(@stores) do |store|
  json.extract! store, :region_id, :name, :desc
  json.url store_url(store, format: :json)
end