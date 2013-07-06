json.array!(@open_shelves) do |open_shelf|
  json.extract! open_shelf, :bay_id, :level, :name, :height, :depth, :thick, :slope, :riser, :notch_num, :color, :from_back, :finger_space
  json.url open_shelf_url(open_shelf, format: :json)
end