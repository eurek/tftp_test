require "rails_helper"

feature "user buys shares" do
  before do
    FactoryBot.create(:content_with_category_and_tag, id: 141)
  end

  scenario "by following the link on become shareholder page" do
    visit become_shareholder_path

    link = find_link("J’achète mes actions", match: :first)

    expect(link[:href]).to eq("https://automate-me.typeform.com/to/ykenkf")
  end

  scenario "and sees the 3 more recent investors" do
    4.times do |index|
      individual = FactoryBot.create(:individual,
        first_name: "first_name_#{index + 1}", last_name: "last_name_#{index + 1}")
      FactoryBot.create(:user, individual: individual)
    end
    visit become_shareholder_path

    expect(page).not_to have_content("First Name 1 Last Name 1")
    expect(page).to have_content("First Name 2 Last Name 2")
    expect(page).to have_content("First Name 3 Last Name 3")
    expect(page).to have_content("First Name 4 Last Name 4")
  end

  context "by choosing between the buying options" do
    before(:each) do
      FactoryBot.create(:shares_purchase)
    end

    scenario "user can access the buy shares choice page" do
      visit buy_shares_choice_path

      expect(page).to have_content("Dites nous ce que vous cherchez.")
    end

    scenario "and their last choice is stored" do
      visit become_shareholder_path(locale: :fr)

      visit buy_shares_choice_path

      expect(page).to have_content("Devenir actionnaire")
      expect(current_path).to eq(become_shareholder_path(locale: :fr))
    end

    scenario "and can acces become shareholder page" do
      visit buy_shares_choice_path(locale: :fr)

      select "Je suis un particulier"
      select "Je souhaite acheter des actions"
      click_button "Go !"

      expect(current_path).to eq(become_shareholder_path(locale: :fr))
      expect(page).to have_content("Devenir actionnaire")
    end

    scenario "and can access become shareholder companies page" do
      visit buy_shares_choice_path(locale: :fr)

      select "Je suis une entreprise"
      select "Je souhaite acheter des actions"
      click_button "Go !"

      expect(current_path).to eq(become_shareholder_company_path(locale: :fr))
      expect(page).to have_content(
        "Un montant plancher de nombre d’action est fixé selon le nombre de collaborateur·ices."
      )
    end

    scenario "user can access offer shares page" do
      visit buy_shares_choice_path(locale: :fr)

      select "Je suis un particulier"
      select "Je souhaite offrir des actions"
      click_button "Go !"

      expect(current_path).to eq(offer_shares_path(locale: :fr))
      expect(page).to have_content("J'offre des actions")
    end

    scenario "and can access offer shares company page" do
      visit buy_shares_choice_path(locale: :fr)

      select "Je suis une entreprise"
      select "Je souhaite offrir des actions"
      click_button "Go !"

      expect(current_path).to eq(offer_shares_company_path(locale: :fr))
      expect(page).to have_content("Offrir des actions avec votre entreprise.")
    end

    scenario "and can access use coupon page" do
      visit buy_shares_choice_path(locale: :fr)

      select "Je suis un particulier"
      select "Je souhaite utiliser mon code cadeau"
      click_button "Go !"

      expect(current_path).to eq(use_gift_coupon_path(locale: :fr))
      expect(page).to have_content("Utiliser mon code cadeau Time for the Planet®")
    end

    scenario "and can go from one shares buying page to another thanks to the secondary navbar", js: true do
      visit become_shareholder_path(locale: :fr)

      find(".choices", text: "un particulier").click
      find(".choices__item", text: "une entreprise").click
      find(".choices", text: "à vous de choisir ...").click
      find(".choices__item", text: "acheter des actions").click

      expect(current_path).to eq(become_shareholder_company_path(locale: :fr))
      expect(page).to have_content(
        "Un montant plancher de nombre d’action est fixé selon le nombre de collaborateur·ices."
      )
    end
  end

  scenario "and sees catch phrase if no day top found" do
    not_displayed_individual = FactoryBot.create(:individual, is_displayed: false)
    displayed_individual = FactoryBot.create(:individual)
    FactoryBot.create(:shares_purchase, amount: 10000, individual: not_displayed_individual,
      completed_at: 1.days.ago)
    FactoryBot.create(:shares_purchase, amount: 5000, individual: displayed_individual,
      completed_at: 2.days.ago)

    visit become_shareholder_path(locale: :fr)

    expect(SharesPurchase.day_top).to eq(nil)
    expect(page).to have_content(I18n.t("become_shareholder.tops.no_top_found"))
  end
end
