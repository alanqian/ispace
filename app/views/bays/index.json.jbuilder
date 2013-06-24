json.array!(@bays) do |bay|
  json.extract! bay, :name, :back_height, :back_width, :back_thick, :back_color, :notch_spacing, :notch_1st, :base_height, :base_width, :base_depth, :base_color, :takeoff_height, :elem_type, :elem_count
  json.url bay_url(bay, format: :json)
end