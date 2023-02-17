FactoryBot.define do
  factory :funded_innovation do
    innovation
    sequence(:amount_invested) { |n| n * 1000000 }
    sequence(:funded_at) { |n| Date.today - n.months }
  end

  trait :with_co2_reduction do
    co2_reduction { {"2022": "1000", "2023": "2000", "2024": "3000", "2025": "4000"} }
  end
end
