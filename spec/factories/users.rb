FactoryBot.define do
  factory :user do
    individual
    password { "password" }
    confirmed_at { DateTime.now }

    trait :not_displayed do
      after :create do |user|
        user.individual.update(is_displayed: false)
      end
    end
  end
end
