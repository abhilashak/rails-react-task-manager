FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user_#{n}@example.com" }

    password { "password@1" }

    trait :with_password_confirmation do
      password_confirmation { password }
    end

    trait :with_invalid_password_confirmation do
      password_confirmation { "inValid@1" }
    end
  end
end
