FactoryBot.define do
  factory :task do
    title { "Improve Product" }
    description { "Improve the product page by minimizing the dependancies" }
    status { 0 }

    association :user

    trait :with_in_progress do
      status { 1 }
    end
  end
end
