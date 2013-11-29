json.array!(@stats) do |stat|
  json.extract! stat, :name, :job_id, :stat_type, :category_id, :plan_set_id, :rel_model, :agg_id, :num_positions, :run, :num_facings, :outcome, :percentage
  json.url stat_url(stat, format: :json)
end
