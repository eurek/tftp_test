FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "name #{n}" }
    description { "description" }
    sequence(:external_uid) { |n| "external_uid#{n}" }
    attributable_to { "user" }

    trait :with_link_in_description do
      after :create do |role|
        role.update(description: "<p>description with <a href=\"https://nada.computer/\">nada</a> link")
      end
    end
  end

  factory :cofounder_role, parent: :role do
    id { 17 }
    name { "Les cofondateurs" }
  end

  factory :scientific_committee_role, parent: :role do
    id { 24 }
    name { "Le conseil scientifique" }
  end

  factory :supervisory_board_role, parent: :role do
    id { 25 }
    name { "Le conseil de surveillance" }
  end
end
