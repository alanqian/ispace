# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stat do
    name "MyString"
    job_id 1
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
  end
end
