FactoryBot.define do
  factory :problem do
    title { "problem title" }
    description { "problem description" }
    action_lever { "zero_emission" }
    domain { "transport" }
    full_content { "full content" }
    position { 1 }

    trait :with_cover do
      after :create do |problem|
        problem.cover_image.attach(
          io: File.open(Rails.root.join("app/assets/images/default-badge-dark.png")),
          filename: "test_image.jpg"
        )
      end
    end
  end
end
