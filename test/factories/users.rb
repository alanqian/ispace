# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password "0000000a"
    password_confirmation "0000000a"
    role 'salesman'

    factory :admin do
      role 'admin'
    end
    factory :designer do
      role 'designer'
    end
  end
end
