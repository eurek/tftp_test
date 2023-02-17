FactoryBot.define do
  factory :individual do
    first_name { "Jane" }
    last_name { "Doe" }
    sequence(:email) { |n| "individual#{n}@email.com" }
    sequence(:external_uid) { |n| "external_uid#{n}" }

    trait :with_picture do
      after :create do |individual|
        individual.picture.attach(
          io: File.open(Rails.root.join("app/assets/images/team.jpg")),
          filename: "test_image.jpg"
        )
      end
    end

    trait :with_picture_and_shares_purchase do
      after :create do |individual|
        individual.picture.attach(
          io: File.open(Rails.root.join("app/assets/images/team.jpg")),
          filename: "test_image.jpg"
        )
        individual.shares_purchases << FactoryBot.create(:shares_purchase)
      end
    end
  end
end
