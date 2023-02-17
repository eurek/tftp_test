FactoryBot.define do
  factory :company do
    name { "Company Inc" }

    trait :with_admin do
      association :admin, factory: :user
    end

    trait :with_creator do
      association :creator, factory: :user
    end

    trait :with_logo do
      after :create do |company|
        company.logo.attach(
          io: File.open(Rails.root.join("app/assets/images/team.jpg")),
          filename: "test_image.jpg"
        )
      end
    end
  end
end
