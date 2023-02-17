require "rails_helper"

feature "user manages their shares purchases" do
  before(:each) do
    @individual = FactoryBot.create(:individual)
    @user = FactoryBot.create(:user, pending: false, individual: @individual)
    login_as(@user, scope: :user)
  end

  scenario "and sees link to buy shares if they didn't" do
    visit shares_purchases_path(locale: :fr)

    expect(page).to have_link("Je deviens actionnaire", href: become_shareholder_path(locale: :fr))
    expect(page).to have_link("En savoir plus", href: become_shareholder_company_path(locale: :fr))
  end

  scenario "by seeing shares purchases total amounts" do
    2.times do
      FactoryBot.create(:shares_purchase, :from_company, amount: "240", individual: @individual, status: "completed")
    end
    2.times do
      FactoryBot.create(:shares_purchase, amount: "130", individual: @individual, status: "completed")
    end
    FactoryBot.create(:shares_purchase, :from_company, amount: "240", individual: @individual, status: "pending")
    FactoryBot.create(:shares_purchase, amount: "130", individual: @individual, status: "pending")
    visit shares_purchases_path(locale: :fr)

    expect(page).to have_content("480")
    expect(page).to have_content("260")
  end

  scenario "by seeing a list of all completed shares purchases they made" do
    5.times do
      FactoryBot.create(:shares_purchase, amount: 240, individual: @individual, status: "completed")
    end
    FactoryBot.create(:shares_purchase, amount: 240, status: "pending")
    visit shares_purchases_path(locale: :fr)

    expect(page).to have_content("240 actions", count: 5)
  end

  scenario "by accessing the page from dashboard", js: true do
    visit user_dashboard_path(locale: :fr)

    find("i", text: "credit_card").click

    expect(page).to have_content("Tes investissements")
    expect(current_path).to eq shares_purchases_path(locale: :fr)
  end

  scenario "can buy new shares if user has has all necessary info" do
    @individual.update!(
      address: "1 rue du Chariot d'Or",
      zip_code: "69004",
      city: "Lyon",
      date_of_birth: "23/06/1994"
    )
    FactoryBot.create(:shares_purchase, status: "completed", individual: @individual)

    visit shares_purchases_path(locale: :fr)

    expect(page).to have_link("Racheter des actions", href: /https:\/\/automate-me.typeform.com\/to\/W5zA0RvK/)
  end

  scenario "can start recurring purchase if user has all necessary info and is shareholder" do
    @individual.update!(
      address: "1 rue du Chariot d'Or",
      zip_code: "69004",
      city: "Lyon",
      date_of_birth: "23/06/1994"
    )
    FactoryBot.create(:shares_purchase, status: "completed", individual: @individual)

    visit shares_purchases_path(locale: :fr)

    expect(page).to have_link("Investir chaque mois", href: /https:\/\/automate-me.typeform.com\/to\/H3NWD1Jq/)
  end

  scenario "can download subscription bulletin" do
    shares_purchase = FactoryBot.create(
      :shares_purchase, :with_subscription_bulletin, amount: 100, individual: @individual, status: "completed"
    )

    visit shares_purchases_path(locale: :fr)

    expect(page).to have_link(
      href: rails_blob_path(shares_purchase.subscription_bulletin, disposition: "attachment", locale: "fr")
    )
  end
end
