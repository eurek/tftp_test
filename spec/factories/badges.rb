FactoryBot.define do
  factory :badge do
    name { "badge name" }
    category { "year" }
    description { "badge description" }
    fun_description { "badge fun description" }
    sequence(:external_uid) { |n| "external_uid#{n}" }
    sequence(:position) { |n| n }

    trait :with_pictures do
      after :create do |badge|
        badge.picture_light.attach(
          io: File.open(Rails.root.join("app/assets/images/team.jpg")),
          filename: "test_image.jpg"
        )

        badge.picture_dark.attach(
          io: File.open(Rails.root.join("app/assets/images/team.jpg")),
          filename: "test_image.jpg"
        )
      end
    end

    trait :with_picture_light do
      after :create do |badge|
        badge.picture_light.attach(
          io: File.open(Rails.root.join("app/assets/images/team.jpg")),
          filename: "test_image.jpg"
        )
      end
    end

    trait :with_picture_dark do
      after :create do |badge|
        badge.picture_dark.attach(
          io: File.open(Rails.root.join("app/assets/images/team.jpg")),
          filename: "test_image.jpg"
        )
      end
    end

    trait :with_link_in_description do
      after :create do |badge|
        badge.update(description: "<p>description with <a href=\"https://nada.computer/\">nada</a> link")
      end
    end
  end
end
