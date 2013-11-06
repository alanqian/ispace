#!/usr/bin/env ruby
# plan/plan_set test script

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

#require 'active_record/fixtures'
#def load_fixture(yml_file)
#  ActiveRecord::Fixtures.create_fixtures(Rails.root.join('test/fixtures'), yml_file)
#end

def define_model_store
  stores = Store.all().first(2)
  Store.define_model_store(stores)
  stores = Store.all().last(2)
  Store.define_model_store(stores)
end

def create_plan_sets
  load_fixture("plan_sets.yml")
end

# rake db:fixtures:load FIXTURES=plan_sets
def prepare_plan_sets
  category_id = "10100"
  PlanSet.destroy_all
  system("rake log:clear")
  system("rake db:fixtures:load FIXTURES=plan_sets")
  plan_sets = PlanSet.all
  plan_sets.each do |plan_set|
    plan_set.category_id = category_id
    plan_set.save!
  end

  # set model stores, init store plans
  model_stores = Store.model_stores.map { |store| store.id.to_s }

  # prepare store fixtures
  fixture_id = 4 # Fixture.first.id
  Store.model_stores.each do |store|
    StoreFixture.upsert_fixture(store.id, category_id, fixture_id)
  end

  src = PlanSet.first
  puts "plan_sets: #{PlanSet.count}, plans:#{Plan.count}"
  dups = {src: src}
  ["new", "finish", "deploying", "deployed"].each do |st|
    name = "#{src.name}-#{st}"
    dups[st] = src.deep_copy(name)
  end

  # set model stores
  plan_set = dups[:src]
  plan_set.model_stores = model_stores

  # plan: select fixture_id
  #       select products
  # plan.auto_position
  # plan.publish
  src.plans.each do |plan|
    plan.init_facing = 2
    plan.optional_products = plan.products_opt.map { |opt| opt.id.to_s }
    plan
    plan.auto_position
    plan.publish
    puts "Plan #{plan.id} published, plan_set:#{src.id}"
  end
end
#prepare_plan_sets

def plan_set_publish(plan_set_id)
  plan_set = PlanSet.find(plan_set_id)
  plan_set.publish
end
plan_set_publish(298486374)

def plan_to_pdf(plan_id)
  plan = Plan.find(plan_id)
  plan.to_pdf
end
#plan_to_pdf(192)

