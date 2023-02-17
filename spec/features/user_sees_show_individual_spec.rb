require "rails_helper"

feature "user sees individual show page" do
  scenario "loads data in o(1)" do
    individual = FactoryBot.create(:individual, is_displayed: true)
    visit shareholder_individual_show_path(individual, {locale: :fr})

    test_sql_predictability(
      -> { individual.badges << FactoryBot.create(:badge, :with_pictures) },
      -> { visit shareholder_individual_show_path(individual, {locale: :fr}) }
    )
  end

  scenario "can see badges and roles on show individual" do
    badge = FactoryBot.create(:badge, :with_pictures)
    role = FactoryBot.create(:role)
    FactoryBot.create(:role)
    individual = FactoryBot.create(:individual)
    individual.roles << role
    FactoryBot.create(:accomplishment, badge_id: badge.id, entity: individual)

    visit shareholder_individual_show_path(individual, locale: "fr")

    expect(page.all("img.BadgeList-badge").count).to eq 1
    expect(page.all("li.RolesList-role").count).to eq 2
    expect(page.all("li.RolesList-role--owned").count).to eq 1
  end

  scenario "can see role description in tooltip", js: true do
    role = FactoryBot.create(:role)
    individual = FactoryBot.create(:individual)
    individual.roles << role

    visit shareholder_individual_show_path(individual, locale: "fr")
    first(".RolesList-role").click

    expect(page.text.include?(role.description)).to eq(true)
  end

  scenario "can see role description and click on link if description has one" do
    role = FactoryBot.create(:role, :with_link_in_description)
    individual = FactoryBot.create(:individual)
    individual.roles << role

    visit shareholder_individual_show_path(individual, locale: "fr")
    first(".RolesList-role").click
    first(".ShareholderAssetTooltip a").click

    expect(current_host).to eq("https://nada.computer")
  end

  scenario "can see badge description in tooltip", js: true do
    badge = FactoryBot.create(:badge)
    individual = FactoryBot.create(:individual)
    individual.badges << badge

    visit shareholder_individual_show_path(individual, locale: "fr")
    first(".BadgeList-badge").click

    expect(page).to have_content(badge.description)
  end

  scenario "display reasons to join if individual's reasons to join exists" do
    individual = FactoryBot.create(:individual, is_displayed: true, reasons_to_join: "reasons")
    visit shareholder_individual_show_path(individual, locale: "fr")

    expect(page).to have_content("Pourquoi j’ai choisi de devenir actionnaire de Time for the Planet")
  end

  scenario "doesn't display reasons to join if individual's reasons to join nil" do
    individual = FactoryBot.create(:individual, is_displayed: true)
    visit shareholder_individual_show_path(individual, locale: "fr")

    expect(page).to have_no_content("Pourquoi j’ai choisi de devenir actionnaire de Time for the Planet")
  end

  scenario "with appropriate prefooter text and link" do
    individual = FactoryBot.create(:individual, is_displayed: true)

    visit shareholder_individual_show_path(individual, locale: "fr")

    expect(page).to have_content(I18n.t(
      "shareholder.prefooter.title_user",
      shareholder_name: individual.decorate.full_name
    ).gsub("&nbsp;", " "))
    expect(page).to have_content(I18n.t("shareholder.prefooter.link_shareholder").gsub("&nbsp;", " ").upcase)
    expect(page.find("a.Button--underlinedDark")["href"]).to eq(buy_shares_choice_path(locale: :fr))
  end

  scenario "display badge category" do
    individual = FactoryBot.create(:individual, is_displayed: true)
    6.times do
      individual.badges << FactoryBot.create(:badge, category: "year")
    end

    visit shareholder_individual_show_path(individual, locale: :fr)

    expect(page).to have_content(
      I18n.t("activerecord.attributes.badge.categories.year").capitalize
    )
    within ".BadgeList--year" do
      expect(page).to have_css(".BadgeList-badge", count: 6)
    end
    expect(page).not_to have_content(
      I18n.t("activerecord.attributes.badge.categories.community").capitalize
    )
    expect(page).not_to have_css(".community")
  end

  scenario "display translated badge category" do
    individual = FactoryBot.create(:individual, is_displayed: true)
    individual.badges << FactoryBot.create(:badge, category: "financial")

    visit shareholder_individual_show_path(individual, locale: :fr)

    expect(page).to have_content("Financier")
    expect(page).not_to have_content("Financial")
  end

  scenario "displays employees counter" do
    individual_1 = FactoryBot.create(:individual, is_displayed: true)
    individual_2 = FactoryBot.create(:individual, is_displayed: true)
    FactoryBot.create(:company, is_displayed: true, employees: [individual_1, individual_2])
    visit shareholder_individual_show_path(individual_1, locale: "fr")

    expect(page).to have_content("2 collaborateur·ices actionnaires")
  end

  scenario "displays employee counter with singular text" do
    individual = FactoryBot.create(:individual, is_displayed: true)
    FactoryBot.create(:company, is_displayed: true, employees: [individual])
    visit shareholder_individual_show_path(individual, locale: "fr")

    expect(page).to have_content("1 collaborateur·ice actionnaire")
  end

  scenario "displays country in right format" do
    individual = FactoryBot.create(:individual, country: "France")

    visit shareholder_individual_show_path(individual, locale: "fr")

    expect(individual.country).to eq("FRA")
    expect(page.find("p.ShareholderDetailedCard-infosBloc").text).to have_content("France")
  end

  scenario "country is translated by select_country gem" do
    individual = FactoryBot.create(:individual, country: "Brazil")

    visit shareholder_individual_show_path(individual, locale: "fr")

    expect(individual.country).to eq("BRA")
    expect(page.find("p.ShareholderDetailedCard-infosBloc").text).to have_content("Brésil")
  end

  scenario "shareholder since is not displayed if user does not have shareholder role" do
    individual = FactoryBot.create(:individual)

    visit shareholder_individual_show_path(individual, locale: "fr")

    expect(page).not_to have_content("Actionnaire depuis le")
  end

  scenario "since date is retrieved from the oldest completed shares purchase" do
    role = FactoryBot.create(:role, external_uid: Role::ROLE_SHAREHOLDER_EXTERNAL_UID)
    individual = FactoryBot.create(:individual, roles: [role])
    4.times do
      individual.shares_purchases << [FactoryBot.build(:shares_purchase, status: "completed", individual: nil)]
    end
    individual.shares_purchases[2].update(completed_at: Date.yesterday)

    visit shareholder_individual_show_path(individual, locale: "fr")

    expect(page).to have_content("Actionnaire depuis le #{I18n.l(Date.yesterday.to_date, format: :default)}")
  end
end
