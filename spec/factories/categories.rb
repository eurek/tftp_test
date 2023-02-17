FactoryBot.define do
  factory :category do
    sequence(:slug) { |n| "category-slug#{n}" }
    sequence(:name) { |n| "category name#{n}" }
    sequence(:title) { |n| "category_title#{n}" }
    sequence(:meta_title) { |n| "category meta_title#{n}" }
    sequence(:meta_description) { |n| "category meta_description#{n}" }
    sequence(:description) { |n| "category description#{n}" }
  end

  factory :press_category, parent: :category do
    title { Category::PRESS_TITLE }
    name { "Parution Presse" }
    slug { "parution-press" }
    published { true }
  end

  factory :blog_category, parent: :category do
    title { "blog" }
    name { "News from the planet (blog)" }
    slug { "blog" }
    published { true }
  end

  factory :faq_category, parent: :category do
    title { "faq" }
    name { "FAQ" }
    slug { "faq" }
    published { true }
  end

  factory :strategy_and_governance_category, parent: :category do
    title { "strategy_and_governance" }
    name { "Stratégie et Gouvernance" }
    slug { "strategie-et-gouvernance" }
    published { true }
  end

  factory :climate_change_category, parent: :category do
    title { "climate_change" }
    name { "Le dérèglement Climatique" }
    slug { "dereglement-climatique" }
    published { true }
  end

  factory :files_category, parent: :category do
    title { "files" }
    name { "Dossier" }
    slug { "dossier" }
    published { true }
  end

  factory :legal_documents, parent: :category do
    title { "legal_documents" }
    name { "Document légaux" }
    slug { "document-legaux" }
    published { true }
  end
end
