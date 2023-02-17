require "rails_helper"

feature "user sees innovations" do
  before(:each) { FactoryBot.create(:investment_brief_content) }

  context "index" do
    scenario "successfully on index page" do
      3.times do
        FactoryBot.create(:innovation)
      end

      visit innovations_path({locale: :fr})

      expect(page).to have_content("Innovations et entreprises crées")
      expect(page).to have_css(".InnovationCard", count: 3)
    end

    scenario "and can filter by status" do
      3.times do
        FactoryBot.create(:innovation)
      end
      FactoryBot.create(:innovation, status: :star)

      visit innovations_path({locale: :fr})
      first(:link, "Etoiles").click

      expect(page).to have_css(".InnovationCard", count: 1)
    end

    scenario "and can filter by domain", js: true do
      3.times do
        FactoryBot.create(:innovation)
      end
      industry = FactoryBot.create(:action_domain, title: "industry", name: "Industry")
      industry.innovations << FactoryBot.create(:innovation)

      visit innovations_path({locale: :fr})
      find("span", text: "Domaines").click
      find("label", text: "Industry").click

      expect(page).to have_content("Enlever les filtres")
      expect(page).to have_css(".AppliedFilter", text: "Industry")
      expect(page).to have_css(".InnovationCard", count: 1)
    end

    scenario "and can filter by lever", js: true do
      3.times do
        FactoryBot.create(:innovation)
      end
      zero_emissions = FactoryBot.create(:action_lever, title: "zero_emission", name: "Zero emissions")
      zero_emissions.innovations << FactoryBot.create(:innovation)

      visit innovations_path({locale: :fr})
      find("span", text: "Levier").click
      find("label", text: "Zero emissions").click

      expect(page).to have_content("Enlever les filtres")
      expect(page).to have_css(".AppliedFilter", text: "Zero emissions")
      expect(page).to have_css(".InnovationCard", count: 1)
    end

    scenario "and can filter by submission episode", js: true do
      3.times do
        FactoryBot.create(:innovation)
      end
      episode = FactoryBot.create(:episode, number: 1, season_number: 0)
      episode.submitted_innovations << Innovation.first

      visit innovations_path({locale: :fr})
      find("span", text: "Episodes").click
      find("label", text: "S00E01").click

      expect(page).to have_content("Enlever les filtres")
      expect(page).to have_css(".AppliedFilter", text: "S00E01")
      expect(page).to have_css(".InnovationCard", count: 1)
    end

    scenario "and can search", js: true do
      3.times do
        FactoryBot.create(:innovation)
      end
      FactoryBot.create(:innovation, founders: ["Michelle"])

      visit innovations_path({locale: :fr})
      fill_in "search", with: "Michelle"

      expect(page).to have_css(".InnovationCard", count: 1)
      expect(page).to have_css(".AppliedFilter", text: "Michelle")
    end

    scenario "and can search and apply multiple filters", js: true do
      innovation_1 = FactoryBot.create(:innovation, founders: ["Michelle"])
      FactoryBot.create(:innovation, founders: ["Michelle"])
      innovation_3 = FactoryBot.create(:innovation)
      innovation_4 = FactoryBot.create(:innovation)

      zero_emissions = FactoryBot.create(:action_lever, title: "zero_emission", name: "Zero emissions")
      zero_emissions.innovations << innovation_1
      zero_emissions.innovations << innovation_3

      industry = FactoryBot.create(:action_domain, title: "industry", name: "Industry")
      industry.innovations << innovation_1
      industry.innovations << innovation_4

      visit innovations_path({locale: :fr})
      fill_in "search", with: "Michelle"
      find("span", text: "Domaines").click
      find("label", text: "Industry").click
      find("span", text: "Levier").click
      find("label", text: "Zero emissions").click

      expect(page).to have_css(".InnovationCard", count: 1)
      expect(page).to have_css(".AppliedFilter", text: "Michelle")
      expect(page).to have_css(".AppliedFilter", text: "Industry")
      expect(page).to have_css(".AppliedFilter", text: "Zero emissions")
      expect(page).to have_content("Enlever les filtres")
    end

    scenario "and can apply a status and a filter", js: true do
      innovation_1 = FactoryBot.create(:innovation, status: "star")
      FactoryBot.create(:innovation, status: "star")
      zero_emissions = FactoryBot.create(:action_lever, title: "zero_emission", name: "Zero emissions")
      zero_emissions.innovations << innovation_1

      visit innovations_path({locale: :fr, status: "star"})
      find("span", text: "Levier").click
      find("label", text: "Zero emissions").click

      expect(page).to have_css(".InnovationCard", count: 1)
      expect(page).to have_css(".AppliedFilter", text: "Etoiles")
      expect(page).to have_css(".AppliedFilter", text: "Zero emissions")
      expect(page).to have_content("Enlever les filtres")
    end

    scenario "can submit an innovation" do
      visit root_path({locale: :fr})

      first(:button, "Agir").click
      first("a", text: /Proposer une innovation/).click

      expect(page).to have_content("Je propose mon innovation")
    end
  end

  context "show" do
    scenario "successfully with minimal information" do
      innovation = FactoryBot.create(:innovation)

      visit innovation_path(innovation, locale: :fr)

      expect(page).to have_content(I18n.t("innovations.show.details.title"))
    end

    scenario "and can go back to index page" do
      innovation = FactoryBot.create(:innovation)

      visit innovation_path(innovation, locale: :fr)
      expect(page).to have_content(I18n.t("innovations.show.details.title"))
      click_link("Retour à la liste")

      expect(page).to have_content("Innovations et entreprises crées")
      expect(current_path).to eq(innovations_path(locale: :fr))
      expect(page).to have_css(".AppliedFilter", text: "Soumises à évaluations")
    end

    scenario "and can go back to index page with filters", js: true do
      industry = FactoryBot.create(:action_domain, title: "industry", name: "Industry")
      img = File.open(Rails.root.join("app/assets/images/logo-time-planet.png"))
      industry.icon.attach(io: img, filename: "test.jpg")
      industry.innovations << FactoryBot.create(:innovation)

      visit innovations_path({locale: :fr})
      find("span", text: "Domaines").click
      find("label", text: "Industry").click
      expect(page).to have_css(".AppliedFilter", text: "Industry")
      find(".InnovationCard").click
      expect(page).to have_content(I18n.t("innovations.show.details.title"))
      click_link("Retour à la liste")

      expect(page).to have_content("Innovations et entreprises crées")
      expect(current_path).to eq(innovations_path(locale: :fr))
      expect(page).to have_css(".AppliedFilter", text: "Industry")
    end
  end
end
