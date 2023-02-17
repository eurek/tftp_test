FactoryBot.define do
  factory :event do
    sequence(:title) { |n| "event title #{n}" }
    locale { :fr }
    category { %i[conference workshop videoconference course].sample }
    sequence(:description) { |n| "event description #{n}" }
    sequence(:date) { |n| DateTime.now + n.days }
    sequence(:venue) { |n| "venue #{n}" }
    sequence(:registration_link) { |n| "https://www.eventbrite.fr/e/inscription-#{n}" }
    sequence(:external_uid) { |n| "rec#{n}" }

    trait :with_picture do
      after :create do |event|
        event.picture.attach(
          io: File.open(Rails.root.join("app/assets/images/default-badge-dark.png")),
          filename: "test_image.jpg"
        )
      end
    end
  end
end
