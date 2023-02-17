require "rails_helper"

feature "user manages their companies" do
  before(:each) do
    @user = FactoryBot.create(:user, pending: false)
  end

  scenario "but can't access the page if not logged in" do
    visit companies_path(locale: :fr)

    expect(page).to have_content("Bienvenue sur ton espace actionnaire !")
    expect(current_path).to eq(new_user_session_path(locale: :fr))
  end

  scenario "but can't access the page if not admin of at least one company" do
    login_as(@user, scope: :user)
    visit companies_path(locale: :fr)

    expect(page).to have_content("Bienvenue sur ton espace actionnaire.")
    expect(current_path).to eq(user_dashboard_path(locale: :fr))
  end

  scenario "but can't see the link in navbar if not admin of at least one company" do
    login_as(@user, scope: :user)
    visit user_dashboard_path(locale: :fr)

    expect(page).not_to have_selector "i.material-icons", text: "apartment"
  end

  scenario "and sees the link to companies index page in navbar" do
    company = FactoryBot.create(:company, admin: @user)
    FactoryBot.create(:shares_purchase, individual: @user.individual, company: company,
      company_info: {name: "Some Name"})
    login_as(@user, scope: :user)
    visit user_dashboard_path(locale: :fr)

    expect(page).to have_selector "i.material-icons", text: "apartment"
  end

  scenario "and can see all their companies" do
    3.times do
      company = FactoryBot.create(:company, admin: @user)
      FactoryBot.create(:shares_purchase, individual: @user.individual, company: company,
        company_info: {name: "Some Name"})
    end
    login_as(@user, scope: :user)
    visit companies_path(locale: :fr)

    expect(page).to have_content("Tes structures")
    expect(page).to have_css(".CompanySharesPurchaseCard", count: 3)
  end

  scenario "and can edit a company" do
    company = FactoryBot.create(:company, admin: @user)
    FactoryBot.create(:shares_purchase, individual: @user.individual, company: company,
      company_info: {name: "Some Name"})
    login_as(@user, scope: :user)
    visit companies_path(locale: :fr)

    click_link "Modifier"
    expect(page).to have_content("Informations sur ton entreprise")
    fill_in "company[name]", with: "Some new name"
    click_button "Valider mon entreprise"
    expect(page).to have_content("Les informations sur ton entreprise ont bien été mises à jour.")
    expect(page).to have_content("Some new name")
    expect(current_path).to eq(companies_path(locale: :fr))
  end

  scenario "and can click to edit a company and go back" do
    company = FactoryBot.create(:company, admin: @user)
    FactoryBot.create(:shares_purchase, individual: @user.individual, company: company,
      company_info: {name: "Some Name"})
    login_as(@user, scope: :user)
    visit companies_path(locale: :fr)

    click_link "Modifier"
    expect(page).to have_content("Informations sur ton entreprise")
    expect(page).to have_content("Revenir à mes entreprises")
    click_link(class: "Onboarding-backlink")

    expect(page).to have_content("Tes structures")
    expect(current_path).to eq(companies_path(locale: :fr))
  end
end
