FactoryBot.define do
  factory :content do
    association :category, factory: :category
    sequence(:slug) { |n| "content-slug#{n}" }
    sequence(:title) { |n| "content title#{n}" }
    sequence(:short_title) { |n| "content short_title#{n}" }
    sequence(:meta_title) { |n| "content meta_title#{n}" }
    sequence(:meta_description) { |n| "content meta_description#{n}" }
    sequence(:body) { |n| "content body#{n}" }
    sequence(:cover_image_url) { |n| "http://cover_img_url_#{n}" }
    sequence(:cover_image_alt) { |n| "cover_img_alt_#{n}" }

    after(:create) do |content, _|
      content.category.update(published: true)
    end

    trait :with_cover do
      after :create do |content|
        content.cover_image.attach(
          io: File.open(Rails.root.join("app/assets/images/default-badge-dark.png")),
          filename: "test_image.jpg"
        )
      end
    end
  end

  factory :content_with_category_and_tag, parent: :content do
    transient do
      tag { FactoryBot.create(:tag, category: Category.last) }
    end

    after(:create) do |content, evaluator|
      content.tags << evaluator.tag
    end
  end

  factory :investment_brief_content, parent: :content_with_category_and_tag do
    id { 44 }
    title { "Dossier d'investissement" }
  end

  factory :event_content, parent: :content_with_category_and_tag do
    id { 33 }
    title { "Organiser ou proposer un événement / une conférence" }
  end

  factory :evaluators_content, parent: :content_with_category_and_tag do
    id { 214 }
    title { "Devenir évaluateur" }
  end

  factory :galaxy_content, parent: :content_with_category_and_tag do
    id { 30 }
    title { "La Galaxie de l’Action Time for the Planet<span class='brand'>®</span>" }
  end

  factory :quick_actions_content, parent: :content_with_category_and_tag do
    id { 591 }
    title { "Actions rapides pour faire grandir Time for the Planet<span class='brand'>®</span>" }
  end

  factory :annual_accounts_content, parent: :content_with_category_and_tag do
    id { 391 }
    title { "Comptes annuels 2020" }
  end

  factory :press_kit_content, parent: :content_with_category_and_tag do
    id { 210 }
    title { "Kit presse" }
  end

  factory :open_source_content, parent: :content_with_category_and_tag do
    id { 556 }
    title { "L'open source" }
  end

  factory :greenwashing_content, parent: :content_with_category_and_tag do
    id { 338 }
    title { "Le greenwashing" }
  end
end
