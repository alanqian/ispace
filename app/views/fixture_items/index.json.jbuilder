json.array!(@fixture_items) do |fixture_item|
  json.extract! fixture_item, :fixture_id, :bay_id, :num_bays, :row, :continuous
  json.url fixture_item_url(fixture_item, format: :json)
end