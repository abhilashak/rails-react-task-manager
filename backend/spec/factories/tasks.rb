FactoryBot.define do
  factory :task do
    title { "Improve Product" }
    description { "Improve the product page by minimizing the dependancies" }
    status { 1 }

    association :user
  end
end
