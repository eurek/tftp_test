FactoryBot.define do
  factory :call_to_action do
    sequence(:text) { |n| "call to action text #{n}" }
    sequence(:href) { |n| "http://time-planet.com/fr/#{n}" }
    sequence(:button_text) { |n| "button text #{n}" }
  end
end
