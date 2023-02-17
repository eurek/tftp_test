FactoryBot.define do
  factory :tag do
    category
    sequence(:slug) { |n| "tag-slug#{n}" }
    sequence(:name) { |n| "tag name#{n}" }
  end
end
