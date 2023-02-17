namespace :categories do
  desc "Update Category"
  task create: :environment do
    puts "Creates categories"
    Category.create(
      title: "communication_documents",
      name_i18n: {fr: "Documents de communication"},
      slug: "communication-documents",
      published: true
    )

    Category.create(
      title: "files",
      name_i18n: {fr: "Dossiers", en: "Files"},
      slug: "files",
      published: true
    )

    Category.create(
      title: "strategy_and_governance",
      name_i18n: {fr: "Stratégie et Gouvernance", en: "Strategy and governance"},
      slug: "strategy-governance",
      published: true
    )

    Category.create(
      title: "faq",
      name_i18n: {fr: "FAQ", en: "FAQ"},
      slug: "faq",
      published: true
    )

    Category.create(
      title: Category::PRESS_TITLE,
      name_i18n: {fr: "Parution Presse", en: "Press clips"},
      slug: "press-clips",
      published: true
    )

    Category.create(
      title: "climate_change",
      name_i18n: {fr: "Le dérèglement climatique", en: "Climate change"},
      slug: "climate-change",
      published: true
    )

    Category.create(
      title: "legal_documents",
      name_i18n: {fr: "Documents légaux", en: "Legal documents"},
      slug: "legal-documents",
      published: true
    )

    Category.create(
      title: "blog",
      name_i18n: {fr: "News from the Planet", en: "News from the Planet"},
      slug: "blog",
      published: true
    )

    Category.create(
      title: "generic_documents",
      name_i18n: {fr: "Documents généraux"},
      slug: "generic-documents",
      published: true
    )

    Category.create(
      title: "time_media",
      name_i18n: {fr: "Le Média"},
      slug: "videos",
      published: true
    )
  end
end
