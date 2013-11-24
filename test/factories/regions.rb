# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :region do
    sequence(:code) { |n| "cn.#{n}" }
    name 'China'
    memo 'test'
  end
end
