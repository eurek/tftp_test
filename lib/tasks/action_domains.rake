namespace :action_domains do
  desc "Create action domains"
  task create: :environment do
    puts "Creates action domains"
    ActionDomain.create(title: "farming", name_i18n: {fr: "Agriculture", en: "Farming"})
    ActionDomain.create(title: "buildings", name_i18n: {fr: "Bâtiment", en: "Buildings"})
    ActionDomain.create(title: "energy", name_i18n: {fr: "Energie", en: "Energy"})
    ActionDomain.create(title: "industry", name_i18n: {fr: "Industrie", en: "Industry"})
    ActionDomain.create(title: "transports", name_i18n: {fr: "Transports", en: "Transport"})
    ActionDomain.create(title: "other", name_i18n: {fr: "Autre", en: "Other"})
  end
end
