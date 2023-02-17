require "rails_helper"

feature "user navigates through navbar", js: true do
  include ContentHelper
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }

  scenario "and cache navbar links" do
    allow(Rails).to receive(:cache).and_return(memory_store)
    cache.clear

    expect(cache.exist?("fr_navbar_menu_links")).to be(false)

    visit root_path({locale: :fr})

    expect(cache.exist?("fr_navbar_menu_links")).to be(true)

    # expires after 10 minutes
    Timecop.freeze(Time.now + 11.minutes) do
      expect(cache.exist?("fr_navbar_menu_links")).to be(false)

      visit root_path({locale: :fr})

      expect(cache.exist?("fr_navbar_menu_links")).to be(true)
    end
  end

  context "click on sub menu Tout Savoir" do
    before(:each) do
      visit root_path({locale: :fr})
      click_on "Tout savoir"
    end

    scenario "and click on Le media" do
      click_on "Le média"

      expect(current_path).to eq(contents_path(category: Category.find_by(title: "time_media").slug, locale: :fr))
      within("h1") do
        expect(page).to have_content("Le Média")
      end
    end
  end

  scenario "click on Devenir évaluateur within sub menu Agir" do
    visit root_path({locale: :fr})

    click_on "Agir"
    click_on "Devenir évaluateur"

    expect(current_path).to eq(custom_content_path(Content.find(214)))
    within("h1") do
      expect(page).to have_content("Devenir évaluateur")
    end
  end

  context "when in another locale than fr" do
    before(:each) do
      I18n.with_locale(:it) do
        Translation.create(key: "common.about", value: "Sapere tutto")
        Translation.create(key: "common.how_to_act", value: "Agire")
        Translation.create(key: "navbar.menus.evaluators.title", value: "Diventa assessor")
        Translation.create(key: "navbar.menus.strategy_and_governance.title", value: "Strategia e governance ")
      end
      I18n.backend.reload!
      Rails.cache.delete("it_navbar_menu_links")
    end

    scenario "link point to category in current locale when category is available in current locale" do
      I18n.locale = :it
      media_category = Category.find_by(title: "strategy_and_governance")
      media_category.update(published: true)

      visit root_path({locale: :it})
      click_on "Sapere tutto"

      expect(page).to have_link("Strategia e governance", href: "/it/about/#{media_category.slug}")
    end

    scenario "link point to content in current locale when content is available in current locale" do
      I18n.locale = :it
      event_content = Content.find(214)
      event_content.update(status: "published")
      event_content.category.update(published: true)

      visit root_path({locale: :it})
      click_on "Agire"

      expect(page).to have_link(
        "Diventa assessor",
        href: "/it/about/#{event_content.category.slug}/#{event_content.slug}"
      )
    end

    scenario "link point to category in english when category is not available in current locale but in english" do
      I18n.locale = :en
      media_category = Category.find_by(title: "strategy_and_governance")
      media_category.update(published: true)

      visit root_path({locale: :it})
      click_on "Sapere tutto"

      expect(page).to have_link("Strategia e governance", href: "/en/about/#{media_category.slug}")
    end

    scenario "link point to content in english when content is not available in current locale but in english" do
      I18n.locale = :en
      event_content = Content.find(214)
      event_content.update(status: "published")
      event_content.category.update(published: true)

      visit root_path({locale: :it})
      click_on "Agire"

      expect(page).to have_link(
        "Diventa assessor",
        href: "/en/about/#{event_content.category.slug}/#{event_content.slug}"
      )
    end

    scenario "link point to category in french when category is only available in french" do
      media = Category.find_by(title: "strategy_and_governance")
      media.update(slug: "strategy-governance")
      visit root_path({locale: :it})
      click_on "Sapere tutto"

      expect(page).to have_link("Strategia e governance", href: "/fr/about/#{media.slug}")
    end

    scenario "link point to content in french when content is only available in french" do
      Content.find(214).update(status: "published")

      visit root_path({locale: :it})
      click_on "Agire"

      expect(page).to have_link("Diventa assessor", href: "/fr/about/category-slug2/content-slug2")
    end
  end

  scenario "and can come back to company home page if lastly visited" do
    FactoryBot.create(:investment_brief_content)
    FactoryBot.create(:press_kit_content)
    FactoryBot.create(:open_source_content)
    FactoryBot.create(:greenwashing_content)
    FactoryBot.create(:cofounder_role)
    FactoryBot.create(:scientific_committee_role)
    FactoryBot.create(:supervisory_board_role)
    I18n.locale = :fr

    visit company_home_path(locale: :fr)
    visit innovations_path(locale: :fr)
    find("a.Navbar-logoContainer").click

    expect(page).to have_content("Votre entreprise peut agir")
    expect(page).to have_current_path(company_home_path(locale: :fr))
  end

  scenario "and can come back to home page if lastly visited" do
    FactoryBot.create(:investment_brief_content)
    I18n.locale = :fr

    visit root_path(locale: :fr)
    visit innovations_path(locale: :fr)
    find("a.Navbar-logoContainer").click

    expect(page).to have_content(
      "Nous, citoyens du monde entier, ne sommes pas résignés face au changement climatique."
    )
    expect(page).to have_current_path(root_path(locale: :fr))
  end
end
