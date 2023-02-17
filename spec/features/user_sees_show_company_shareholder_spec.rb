require "rails_helper"

feature "user sees company show page" do
  scenario "loads data in o(1)" do
    company = FactoryBot.create(:company, :with_admin, is_displayed: true)
    visit shareholder_company_show_path(company, {locale: :fr})

    test_sql_predictability(
      -> { company.employees << FactoryBot.create(:individual, :with_picture) },
      -> { visit shareholder_company_show_path(company, {locale: :fr}) }
    )
  end

  scenario "displays company's employees shareholders" do
    individual_1 = FactoryBot.create(:individual, is_displayed: true)
    individual_2 = FactoryBot.create(:individual, is_displayed: true)
    creator = FactoryBot.create(:user, individual: individual_1)
    company = FactoryBot.create(:company, is_displayed: true, creator: creator, employees: [individual_1, individual_2])

    visit shareholder_company_show_path(company, locale: "fr")

    expect(page.all("a.ShareholderCard").count).to eq 2
    expect(page).to have_content("2 collaborateur·ices actionnaires")
  end

  scenario "displays company's single employee shareholder" do
    individual = FactoryBot.create(:individual, is_displayed: true)
    creator = FactoryBot.create(:user, individual: individual)
    company = FactoryBot.create(:company, is_displayed: true, creator: creator, employees: [individual])

    visit shareholder_company_show_path(company, locale: "fr")

    expect(page.all("a.ShareholderCard").count).to eq 1
    expect(page).to have_content("1 collaborateur·ice actionnaire")
  end

  context "shareholder" do
    scenario "can see its badges and roles" do
      badge = FactoryBot.create(:badge, :with_pictures, category: "year")
      role = FactoryBot.create(:role, attributable_to: "company")
      FactoryBot.create(:role, attributable_to: "company")
      company = FactoryBot.create(:company, :with_admin, roles: [role], is_displayed: true)
      FactoryBot.create(:accomplishment, badge_id: badge.id, entity: company)

      visit shareholder_company_show_path(company, locale: "fr")

      expect(page.all("img.BadgeList-badge").count).to eq 1
      expect(page.all("li.RolesList-role").count).to eq 2
      expect(page.all("li.RolesList-role--owned").count).to eq 1
    end

    scenario "displays company's description and co2_emissions_reduction_actions if exists" do
      shareholder = FactoryBot.create(
        :company,
        :with_admin,
        is_displayed: true,
        description: "description",
        co2_emissions_reduction_actions: "actions"
      )
      visit shareholder_company_show_path(shareholder, locale: "fr")

      expect(page).to have_content(shareholder.description)
      expect(page).to have_content(shareholder.co2_emissions_reduction_actions)
    end

    scenario "doesn't displays company's description and co2_emissions_reduction_actions if nil" do
      shareholder = FactoryBot.create(:company, :with_admin, is_displayed: true)
      visit shareholder_company_show_path(shareholder, locale: "fr")

      expect(page).to have_no_content("Présentation")
      expect(page).to have_no_content("réduit en interne ses émissions de CO2")
    end

    scenario "can see appropriate prefooter text and link" do
      shareholder = FactoryBot.create(:company, :with_admin, is_displayed: true)

      visit shareholder_company_show_path(shareholder, locale: "fr")

      expect(page).to have_content(I18n.t(
        "shareholder.prefooter.title_shareholder_company",
        shareholder_name: shareholder.name
      ).gsub("&nbsp;", " "))
      expect(page).to have_content(I18n.t(
        "shareholder.prefooter.link_shareholder",
        shareholder_name: shareholder.name
      ).gsub("&nbsp;", " ").upcase)
      expect(page.find("a.Button--underlinedBlackPurple")["href"]).to eq(buy_shares_choice_path(locale: :fr))
    end
  end

  context "not shareholder yet" do
    scenario "can see appropriate content" do
      creator = FactoryBot.create(:user)
      company = FactoryBot.create(:company, creator: creator, is_displayed: true)

      visit shareholder_company_show_path(company, locale: "fr")

      expect(page).to have_content(I18n.t("shareholder.company_show.not_yet_shareholder"))
      expect(page).to have_content("#{company.name} n’est pas encore actionnaire de Time for the Planet®...")
    end

    scenario "can see appropriate prefooter text and link" do
      creator = FactoryBot.create(:user)
      company = FactoryBot.create(:company, creator: creator, is_displayed: true)

      visit shareholder_company_show_path(company, locale: "fr")

      expect(page).to have_content(I18n.t(
        "shareholder.prefooter.title_company",
        shareholder_name: company.name
      ).gsub("&nbsp;", " ").gsub("<span class='brand'>®</span>", "®"))
      expect(page).to have_content(I18n.t(
        "shareholder.prefooter.link_company",
        shareholder_name: company.name
      ).gsub("&nbsp;", " ").gsub("<span class='brand'>®</span>", "®").upcase)
      expect(page.find("a.Button--underlinedBlackPurple")["href"]).to eq("https://automate-me.typeform.com/to/XX9l9YFn")
    end
  end
end
