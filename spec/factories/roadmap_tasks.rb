FactoryBot.define do
  factory :roadmap_task do
    sequence(:title) { |n| "title #{n}" }
    text { "Task text" }
    done_at { nil }
    duration_type { "short" }
    category { "community" }
  end
end
