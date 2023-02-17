FactoryBot.define do
  factory :shares_purchase do
    amount { 100 }
    form_completed_at { Time.now }
    payment_method { SharesPurchase.payment_methods.keys.sample }
    association :individual
    sequence(:external_uid) { |n| "external_uid#{n}" }
    sequence(:typeform_answer_uid) { |n| "typeform_answer_uid#{n}" }
    # TODO: Maybe remove completed_at from here and make a trait :completed with this
    completed_at { DateTime.now }

    trait :from_company do
      association :company
      company_info { {name: company.name} }
    end

    trait :with_subscription_bulletin do
      after :create do |shares_purchase|
        shares_purchase.subscription_bulletin.attach(
          io: File.open(Rails.root.join("spec/support/assets/bulletin.pdf")),
          filename: "bulletin.pdf"
        )
      end
    end
  end
end
