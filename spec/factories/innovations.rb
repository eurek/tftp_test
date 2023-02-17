FactoryBot.define do
  factory :innovation do
    sequence(:external_uid) { |n| "external_uid#{n}" }
    name { "Innovation's name" }
    status { "received" }
    rating { 3 }

    trait :with_picture do
      after :create do |innovation|
        innovation.picture.attach(
          io: File.open(Rails.root.join("app/assets/images/team.jpg")),
          filename: "test_image.jpg"
        )
      end
    end
  end
end
