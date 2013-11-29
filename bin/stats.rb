#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

Stat.delete_all

# create default user for each store
brands = Brand.where(category_id: "830506").select(:id, :name)
stats = []
total_facings = 0
total_positions = 0
brands.each do |brand|
  stat = Stat.new(
    name: "品类排面统计",
    job_id: 1,
    stat_type: "品类统计",
    category_id: "830506",
    plan_set_id: 100,
    rel_model: "brand",
    agg_id: brand.id,
    # agg_name: brand.name,
    run: rand(200) + 100,
    num_facings: rand(20) + 30,
    outcome: rand(199990) / 100.0,
    percentage: 0.0,
  )
  stat.num_positions = stat.num_facings * (rand(18) + 3)
  stats.push stat
  total_facings += stat.num_facings
  total_positions += stat.num_positions
end

stats.each do |stat|
  stat.percentage = stat.num_facings * 100.0 / total_facings
  stat.save!
end
Stat.create(
    name: "品类排面统计",
    job_id: 1,
    stat_type: "品类统计",
    category_id: "830506",
    plan_set_id: 100,
    rel_model: "brand",
    agg_id: 0,
    num_positions: total_positions,
    num_facings: total_facings,
    outcome: rand(199990) / 100.0,
    percentage: 100.0,
)
#puts brands.to_json

__END__

Brand.all.each do |store|
  Stat.create(
    name: "MyString"
    job_id: 1
    stat_type "MyString"
    category_id "MyString"
    plan_set_id 1
    rel_model "MyString"
    agg_id 1
    num_positions 1
    run 1
    num_facings 1
    outcome "9.99"
    percentage "9.99"
  )
end

