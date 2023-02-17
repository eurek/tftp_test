FactoryBot.define do
  factory :episode do
    sequence(:season_number)
    number { rand(1..4) }
    sequence(:started_at) { |n| CurrentSituation::FUNDRAISING_START_DATE + n.months }
    sequence(:finished_at) { |n| CurrentSituation::FUNDRAISING_START_DATE + 2.months + n.months }

    trait :current do
      number { 42 }
      season_number { 42 }
      started_at { Time.now - 1.month }
      finished_at { Time.now + 1.month }
      fundraising_goal { 1000000000 }
    end

    trait :with_cover_image do
      after :create do |episode|
        episode.cover_image.attach(
          io: File.open(Rails.root.join("app/assets/images/team.jpg")),
          filename: "test_image.jpg"
        )
      end
    end
  end
end
