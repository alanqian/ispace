json.array!(@fixtures) do |fixture|
  json.extract! fixture, :name, :code, :user_id, :category_id, :run, :linear, :area, :cube, :flow_l2r
  json.url fixture_url(fixture, format: :json)
end
