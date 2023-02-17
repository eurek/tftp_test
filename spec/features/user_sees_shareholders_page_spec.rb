require "rails_helper"

feature "user sees shareholders page" do
  scenario "loads data in o(1)" do
    individual = FactoryBot.create(:individual, is_displayed: true)
    FactoryBot.create(:badge, :with_pictures)
    visit shareholders_path({locale: :fr})

    test_sql_predictability(
      -> { individual.badges << FactoryBot.create(:badge, :with_pictures) },
      -> { visit shareholders_path({locale: :fr}) }
    )
  end

  scenario "should render paginated list by 40" do
    45.times { FactoryBot.create(:individual, is_displayed: true) }

    visit shareholders_path

    expect(page).to have_css(".ShareholderCard", count: 40)
  end

  scenario "can search individual by first name" do
    FactoryBot.create(:individual, first_name: "Kévin", is_displayed: true, current_job: "dev")
    visit shareholders_path({locale: :fr})

    fill_in("search", with: "Kevin")
    click_button("Rechercher")

    expect(page).to have_content("1 profil")
    expect(find(".ShareholderCard")).to have_content("Kévin")
  end

  scenario "can search individual with partial last name" do
    FactoryBot.create(:individual, last_name: "Mitnick", is_displayed: true)
    visit shareholders_path

    fill_in("search", with: "Mit")
    click_button("Rechercher")

    expect(page).to have_css(".ShareholderCard", count: 1)
    expect(find(".ShareholderCard")).to have_content("Mitnick")
  end

  scenario "display no result if no individual match search input" do
    FactoryBot.create(:individual, is_displayed: true)
    visit shareholders_path

    fill_in("search", with: "Mit")
    click_button("Rechercher")

    expect(page).to have_content("0 profil")
  end

  scenario "can click on individual card and see show" do
    shareholder = FactoryBot.create(:individual, is_displayed: true)

    visit shareholders_path({locale: "fr"})

    page.all("a.ShareholderCard").first.click

    expect(current_path).to eq(shareholder_individual_show_path(shareholder, locale: "fr"))
  end

  scenario "can click on company card and see show" do
    company = FactoryBot.create(:company, :with_admin, is_displayed: true)

    visit shareholders_path({locale: "fr"})

    page.all("a.ShareholderCard").first.click

    expect(current_path).to eq(shareholder_company_show_path(company, locale: "fr"))
  end

  scenario "can see individual's roles if individual has roles" do
    individual = FactoryBot.create(:individual, is_displayed: true)
    individual.roles = [FactoryBot.create(:role)]

    visit shareholders_path({locale: "fr"})

    expect(page).to have_css(".Sticker", count: 1)
  end

  scenario "cannot display roles if individual has no role" do
    FactoryBot.create(:individual, is_displayed: true)

    visit shareholders_path({locale: "fr"})

    expect(page).to have_css(".Sticker", count: 0)
  end

  scenario "can see two first roles if individual has more than 3 roles and display a +1 sticker" do
    individual = FactoryBot.create(:individual, is_displayed: true)
    3.times { individual.roles << FactoryBot.create(:role) }

    visit shareholders_path({locale: "fr"})

    expect(page).to have_css(".Sticker", count: 3)
    expect(page.all(".Sticker").last.text).to eq("+1")
  end

  scenario "can see company role as constant role" do
    company = FactoryBot.create(:company, :with_admin, is_displayed: true)
    company.roles << FactoryBot.create(:role, name: "Actionnaire", attributable_to: "company")

    visit shareholders_path({locale: "fr"})

    expect(page.all(".Sticker").first.text)
      .to eq(I18n.t("shareholder.index.company_stickers.sticker_1"))
    expect(page.all(".Sticker").last.text).to eq(I18n.t("shareholder.index.company_stickers.sticker_2"))
  end

  scenario "can see company as shareholder if it is" do
    company = FactoryBot.create(:company, :with_admin, is_displayed: true)
    company.roles << FactoryBot.create(:role, name: "Actionnaire", attributable_to: "company")

    visit shareholders_path({locale: "fr"})

    expect(page.all(".Sticker").first.text)
      .to eq(I18n.t("shareholder.index.company_stickers.sticker_1"))
  end

  scenario "can see company as not shareholder if it is not" do
    FactoryBot.create(:company, :with_creator, is_displayed: true)

    visit shareholders_path({locale: "fr"})

    expect(page.all(".Sticker").first.text)
      .not_to eq(I18n.t("shareholder.index.company_stickers.sticker_1"))
  end

  context "using filters", js: true do
    before(:each) do
      5.times { FactoryBot.create(:individual, is_displayed: true) }
    end

    scenario "can apply one badge filter and url query params is updated with js" do
      badge = FactoryBot.create(:badge, :with_pictures, name: "Licorne")
      Individual.last(5).map { |individual| FactoryBot.create(:accomplishment, badge: badge, entity: individual) }

      visit shareholders_path({locale: "fr"})

      page.find(".Filters-item", text: "Badges").click
      page.all("label").last.click

      expect(page).to have_content("5 profils")
      expect(page).to have_current_path("/fr/shareholders?filters%5Btypes%5D%5B%5D="\
        "&filters%5Bbadges%5D%5B%5D=&filters%5Bbadges%5D%5B%5D=#{Badge.last.id}&filters%5Broles%5D%5B%5D="\
        "&filters%5Bcountries%5D%5B%5D=&search=")
    end

    scenario "can apply multiple badge filters" do
      individual_1 = FactoryBot.create(:individual, is_displayed: true)
      individual_2 = FactoryBot.create(:individual, is_displayed: true)
      badge = FactoryBot.create(:badge, :with_pictures, name: "Licorne")
      badge_2 = FactoryBot.create(:badge, :with_pictures, name: "Suricat")
      FactoryBot.create(:accomplishment, badge: badge_2, entity: individual_1)
      FactoryBot.create(:accomplishment, badge: badge, entity: individual_2)

      visit shareholders_path

      page.find(".Filters-item", text: "Badges").click

      page.all(".Filters-badgesImage").first.click
      page.all(".Filters-badgesImage").last.click

      expect(page).to have_content("Enlever les filtres")
      expect(page).to have_content("2 profils")
    end

    scenario "can apply badge and role filters" do
      badge = FactoryBot.create(:badge, :with_pictures, name: "Licorne")
      individual = Individual.last
      FactoryBot.create(:accomplishment, badge: badge, entity: individual)
      role = FactoryBot.create(:role, name: "QA")
      individual.roles << role

      visit shareholders_path

      page.find(".Filters-item", text: "Badges").click
      page.all(".Filters-badgesImage").first.click

      page.find(".Filters-item", text: "Roles").click
      page.find("label", text: "Qa").click

      expect(page).to have_content("Enlever les filtres")
      expect(page).to have_content("1 profil")
    end

    scenario "can filter by role" do
      individual = Individual.last
      role = FactoryBot.create(:role, name: "QA")
      individual.roles << role

      visit shareholders_path
      page.find(".Filters-item", text: "Roles").click
      page.find("label", text: "Qa").click

      expect(page).to have_content("Enlever les filtres")
      expect(page).to have_content("1 profil")
    end

    scenario "can filter by type" do
      FactoryBot.create(:company, :with_admin, is_displayed: true)

      visit shareholders_path

      page.find(".Filters-item", text: "Entreprise").click

      expect(page).to have_content("Enlever les filtres")
      expect(page).to have_content("1 profil")
    end

    scenario "can filter on search results" do
      badge = FactoryBot.create(:badge, :with_pictures, name: "Elephant")
      individual = FactoryBot.create(:individual, last_name: "Mitnick", is_displayed: true, current_job: "dev")
      FactoryBot.create(:accomplishment, badge: badge, entity: individual)

      visit shareholders_path

      fill_in("search", with: "Mit")
      click_button("Rechercher")

      page.find(".Filters-item", text: "Badges").click
      page.all(".Filters-badgesImage").first.click

      expect(page).to have_content("1 profil")
      expect(find(".ShareholderCard")).to have_content("Mitnick")
    end

    scenario "find a individual that match search query, with role, but without the badge" do
      badge = FactoryBot.create(:badge, :with_pictures, name: "Licorne")
      individual = FactoryBot.create(:individual, first_name: "Mary", is_displayed: true)
      individual2 = FactoryBot.create(:individual, first_name: "Albert", is_displayed: true)
      role = FactoryBot.create(:role, name: "QA")
      individual2.badges << badge
      individual.roles << role

      visit shareholders_path

      fill_in("search", with: "mary")
      click_button("Rechercher")

      page.find(".Filters-item", text: "Badges").click
      page.all(".Filters-badgesImage").first.click

      page.find(".Filters-item", text: "Roles").click
      page.find("label", text: "Qa").click

      expect(page).to have_content("Enlever les filtres")
      expect(page).to have_content("0 profil")
    end

    scenario "can filter by country" do
      FactoryBot.create(:individual, country: "FRA")
      FactoryBot.create(:individual, country: "ITA", first_name: "Mario")
      visit shareholders_path(locale: :fr)

      page.find(".Filters-item", text: "Pays").click
      find("label", text: "Italie").click

      expect(page).to have_content("Enlever les filtres")
      expect(page).to have_content("1 profil")
      expect(page).to have_content("Mario")
    end
  end

  context "and sees shareholder badges displayed properly" do
    scenario "when shareholder has 6 or less badges all badges are displayed as images" do
      individual = FactoryBot.create(:individual, is_displayed: true)
      6.times do
        individual.badges << FactoryBot.create(:badge, :with_pictures)
      end

      visit shareholders_path

      expect(page).to have_content("1 profil")
      expect(page).not_to have_css(".ShareholderCard-badge--last")
    end

    scenario "when shareholder has 7 or more, 5 badges are displayed as images and additional number is displayed" do
      individual = FactoryBot.create(:individual, is_displayed: true)
      7.times do
        individual.badges << FactoryBot.create(:badge, :with_pictures)
      end

      visit shareholders_path

      expect(page).to have_content("1 profil")
      expect(page).to have_css(".ShareholderCard-badge--last", text: "+2")
    end
  end

  context "map" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }

    scenario "and cache statistics" do
      allow(Rails).to receive(:cache).and_return(memory_store)
      cache.clear

      expect(cache.exist?("shareholders_map_markers")).to be(false)

      visit shareholders_map_path

      expect(cache.exist?("shareholders_map_markers")).to be(true)

      # expires after 10 minutes
      Timecop.freeze(Time.now + 1.day) do
        expect(cache.exist?("shareholders_map_markers")).to be(false)

        visit shareholders_map_path

        expect(cache.exist?("shareholders_map_markers")).to be(true)
      end
    end
  end
end
