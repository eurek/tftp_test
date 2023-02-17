FactoryBot.define do
  factory :statistic do
    sequence(:date) { |n| Date.parse("2019/01") + n.months }
  end
end
