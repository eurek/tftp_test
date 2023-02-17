namespace :action_levers do
  desc "Create action levers"
  task create: :environment do
    puts "Creates action levers"
    ActionLever.create(title: "zero_emissions", name_i18n: {fr: "Zéro émission", en: "Zero emissions"})
    ActionLever.create(title: "sobriety", name_i18n: {fr: "Sobriété", en: "Sobriety"})
    ActionLever.create(title: "capture", name_i18n: {fr: "Captation", en: "Capture"})
    ActionLever.create(
      title: "energetic_efficiency",
      name_i18n: {fr: "Efficacité énergétique", en: "Energy efficiency"}
    )
    ActionLever.create(title: "other", name_i18n: {fr: "Autre", en: "Other"})
  end
end
