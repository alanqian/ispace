json.array!(@freezer_chests) do |freezer_chest|
  json.extract! freezer_chest, :bay_id, :level, :name, :height, :depth, :inside_height, :wall_thick, :merch_height
  json.url freezer_chest_url(freezer_chest, format: :json)
end