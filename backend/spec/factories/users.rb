FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.com" }

    password { "password@1" }
  end
end
