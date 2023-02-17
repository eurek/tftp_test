require "rails_helper"

feature "user associates shares purchase to a company" do
  before(:each) do
    search_call_url = "https://api.opencorporates.com/v0.4/companies/search"
    search_call_response_body = File.open(Rails.root.join("spec/mocks/open_corporates/search_mock.json")).read
    stub_request(:get, /#{Regexp.quote(search_call_url)}/).to_return(status: 200, body: search_call_response_body)
    @user = FactoryBot.create(:user, pending: false)
    @shares_purchase = FactoryBot.create(:shares_purchase,
      company_info: {name: "Nada"}, individual: @user.individual, status: "completed")
    login_as(@user, scope: :user)
  end

  scenario "present in DB" do
    FactoryBot.create(:company, name: "Nada")
    visit shares_purchases_path(locale: :fr)

    click_link "Associer ma structure"
    click_link("Nada")

    expect(current_path).to eq(edit_company_path(locale: :fr, id: Company.first.id))
    expect(SharesPurchase.first.company).to eq(Company.first)
    expect(Company.count).to eq(1)
    expect(Company.first.admin).to eq(@user)
  end

  scenario "and can go back to company choice from company edition page" do
    FactoryBot.create(:company, name: "Nada")
    visit shares_purchases_path(locale: :fr)

    click_link "Associer ma structure"
    click_link "Nada"
    click_link(class: "Onboarding-backlink")

    expect(page).to have_current_path(choose_company_path(
      locale: :fr,
      search: {name: "Nada"},
      shares_purchase_id: SharesPurchase.first.id
    ))
    expect(page).to have_field("search[name]", with: "Nada")
  end

  scenario "present in Open Corporate API" do
    visit shares_purchases_path(locale: :fr)

    click_link "Associer ma structure"
    fill_in "search[name]", with: "France Television"
    find("input.Button.Button--inline.Button--box").click
    click_link("France Television Publicite Conseil", match: :first)

    expect(current_path).to eq(edit_company_path(locale: :fr, id: Company.first.id))
    expect(SharesPurchase.first.company).to eq(Company.first)
    expect(Company.count).to eq(1)
    company = Company.first
    expect(company.admin).to eq(@user)
    expect(company.name).to eq("France Television Publicite Conseil")
    expect(company.attributes.except("id", "created_at", "updated_at", "admin_id", "public_slug")).to eq(
      {
        "name" => "France Television Publicite Conseil",
        "address" => "64 A 70 64 Avenue J B Clement\n92100 Boulogne Billancourt, Hauts De Seine, France",
        "description" => nil,
        "co2_emissions_reduction_actions" => nil,
        "linkedin" => nil,
        "facebook" => nil,
        "website" => nil,
        "is_displayed" => true,
        "open_corporates_company_number" => "382258622",
        "open_corporates_jurisdiction_code" => "fr",
        "latitude" => nil,
        "longitude" => nil,
        "country" => "FRA",
        "creator_id" => nil,
        "legal_form" => nil,
        "structure_size" => nil,
        "city" => "Boulogne-Billancourt",
        "zip_code" => "92100",
        "street_address" => "64 A 70 64 Avenue J B Clement"
      }
    )
  end

  scenario "and can remove an association", js: true do
    company = FactoryBot.create(:company, name: "Nada")

    @shares_purchase.update(company: company)

    visit shares_purchases_path(locale: :fr)
    find("i", text: "delete").click

    expect(page).to have_content("L'association a bien été supprimée.")
    expect(current_path).to eq shares_purchases_path(locale: :fr)
    expect(@shares_purchase.reload.company).to be nil
  end

  context "by adding a new company" do
    scenario "unsuccessfully because no shares purchase id is present" do
      visit new_company_path(locale: :fr)

      expect(current_path).to eq shares_purchases_path(locale: :fr)
    end

    scenario "unsuccessfully because the shares purchase doesn't exist" do
      visit new_company_path(locale: :fr, shares_purchase_id: @shares_purchase.id + 1)

      expect(current_path).to eq shares_purchases_path(locale: :fr)
    end

    scenario "unsuccessfully because the shares purchase wasn't made by a company" do
      @shares_purchase.update(company_info: nil)
      visit new_company_path(locale: :fr, shares_purchase_id: @shares_purchase.id)

      expect(current_path).to eq shares_purchases_path(locale: :fr)
    end

    scenario "unsuccessfully because name is missing" do
      visit new_company_path(locale: :fr, shares_purchase_id: @shares_purchase.id)

      fill_in "company[name]", with: ""
      click_button "Valider mon entreprise"

      expect(current_path).to eq(companies_path(locale: :fr))
      expect(page).to have_content("Merci d'indiquer nom de l'entreprise")
    end

    scenario "successfully with only name" do
      visit shares_purchases_path(locale: :fr)
      click_link "Associer ma structure"
      fill_in "search[name]", with: "Nada"
      find("input.Button.Button--inline.Button--box").click
      click_link "Ajouter une entreprise"

      click_button "Valider mon entreprise"

      expect(current_path).to eq(shares_purchases_path(locale: :fr))
      expect(SharesPurchase.first.company).to eq(Company.first)
      expect(Company.count).to eq(1)
      expect(Company.first.admin).to eq(@user)
      expect(Company.first.name).to eq("Nada")
    end

    scenario "with all given information" do
      visit shares_purchases_path(locale: :fr)
      click_link "Associer ma structure"
      fill_in "search[name]", with: "Nada"
      find("input.Button.Button--inline.Button--box").click
      click_link "Ajouter une entreprise"

      fill_in "company[address]", with: "Street, City"
      fill_in "company[description]", with: "Description"
      fill_in "company[co2_emissions_reduction_actions]", with: "Some things I guess?"
      fill_in "company[website]", with: "https://mywebsite.com"
      fill_in "company[facebook]", with: "https://facebook.com/pg/some_page"
      fill_in "company[linkedin]", with: "https://linkedin.com/29879820O2"
      click_button "Valider mon entreprise"

      expect(current_path).to eq(shares_purchases_path(locale: :fr))
      company = @user.reload.companies.first
      expect(Company.count).to eq(1)
      expect(company.name).to eq "Nada"
      expect(company.address).to eq "Street, City"
      expect(company.description).to eq "Description"
      expect(company.co2_emissions_reduction_actions).to eq "Some things I guess?"
      expect(company.website).to eq "https://mywebsite.com"
      expect(company.facebook).to eq "https://facebook.com/pg/some_page"
      expect(company.linkedin).to eq "https://linkedin.com/29879820O2"
      expect(company.admin).to eq @user
    end

    scenario "with a logo" do
      file_path = Rails.root.join("spec", "support", "assets", "picture-profile.jpg")
      visit shares_purchases_path(locale: :fr)
      click_link "Associer ma structure"
      fill_in "search[name]", with: "Nada"
      find("input.Button.Button--inline.Button--box").click
      click_link "Ajouter une entreprise"

      attach_file("company[logo]", file_path)
      click_button "Valider mon entreprise"

      expect(Company.count).to eq(1)
      expect(current_path).to eq(shares_purchases_path(locale: :fr))
      expect(@user.companies.first.reload.logo.attached?).to be true
    end

    scenario "unsuccessfully because image format is bad" do
      file_path = Rails.root.join("spec", "support", "assets", "profile.heif")
      visit shares_purchases_path(locale: :fr)
      click_link "Associer ma structure"
      fill_in "search[name]", with: "Nada"
      find("input.Button.Button--inline.Button--box").click
      click_link "Ajouter une entreprise"

      attach_file("company[logo]", file_path, visible: false)
      click_button "Valider mon entreprise"

      expect(Company.count).to eq(0)
      expect(page).to have_content("logo doit être au format jpg, jpeg ou png")
      expect(@user.companies.empty?).to be true
    end
  end
end
