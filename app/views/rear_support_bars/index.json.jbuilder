json.array!(@rear_support_bars) do |rear_support_bar|
  json.extract! rear_support_bar, :bay_id, :level, :name, :height, :bar_depth, :bar_thick, :from_back, :hook_length, :notch_num, :color
  json.url rear_support_bar_url(rear_support_bar, format: :json)
end