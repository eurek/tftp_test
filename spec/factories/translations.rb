FactoryBot.define do
  factory :translation do
    key { (1..rand(2..4)).map { Faker::Lorem.word }.join(".") }
    value_i18n { I18n.available_locales.sample(rand(2..4)).map { |l| [l, Faker::Lorem.sentence] }.to_h }
  end
end
