# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :store do
    name 'test store 1'
    sequence(:code) { |n| "#{n}" }
    area 'center'
  end
end
