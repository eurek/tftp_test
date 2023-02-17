FactoryBot.define do
  factory :accomplishment do
    association :badge
    association :entity, factory: :individual

    trait :for_company do
      association :entity, factory: :individual
    end

    factory :accomplishment_for_company, traits: [:for_company]
  end
end
