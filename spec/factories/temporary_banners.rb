FactoryBot.define do
  factory :temporary_banner do
    headline { "Next Event" }
    cta { "subscribe" }
    link { "https://event-url.com" }
  end
end
