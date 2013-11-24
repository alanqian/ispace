json.array!(@stores) do |store|
  json.extract! store, :region_id, :code, :name, :ref_store_id, :area, :location, :memo
  json.url store_url(store, format: :json)
end
