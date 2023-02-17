FactoryBot.define do
  factory :page do
    title { "Page's title" }
    sequence(:slug) { |n| "page-slug-#{n}" }
    body { "body content" }
  end
end
