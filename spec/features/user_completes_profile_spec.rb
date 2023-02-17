require "rails_helper"

feature "user completes profile" do
  before(:each) do
    @individual = FactoryBot.create(:individual, first_name: "Jane", last_name: "Doe")
    @user = FactoryBot.create(:user, individual: @individual)
    login_as(User.find(@user.id), scope: :user)
    visit user_profile_path(locale: :fr)
  end

  context "unsuccessfully" do
    scenario "because date of birth is before allowed range" do
      fill_in "individual[date_of_birth]", with: "01/01/1800"
      click_button "Valider mon profil"

      expect(current_path).to eq(update_user_path(locale: :fr))
      expect(page).to have_content("ta date de naissance est incorrect(e)")
    end

    scenario "because date of birth is after allowed range" do
      fill_in "individual[date_of_birth]", with: (Date.today + 1).to_s
      click_button "Valider mon profil"

      expect(current_path).to eq(update_user_path(locale: :fr))
      expect(page).to have_content("ta date de naissance est incorrect(e)")
    end

    scenario "because picture content_type is not correct" do
      file_path = Rails.root.join("spec", "support", "assets", "profile.heif")
      attach_file(file_path)
      click_button "Valider mon profil"

      expect(current_path).to eq(update_user_path(locale: :fr))
      expect(page).to have_content("ta photo doit être au format jpg, jpeg ou png")
    end

    scenario "and employer is still editable" do
      company = FactoryBot.create(:company, name: "Nada", creator: @user)
      @individual.update(employer: company)
      visit current_path

      fill_in "individual[date_of_birth]", with: "01/01/1800"
      click_button "Valider mon profil"

      expect(current_path).to eq(update_user_path(locale: :fr))
      expect(page).to have_css("h2", text: "Nada")
      expect(page).to have_content("Modifier les informations")
    end
  end

  context "successfully" do
    scenario "and doesn't want their profile to be visible" do
      uncheck "Je souhaite apparaitre dans la liste des actionnaires"
      click_button "Valider mon profil"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
    end

    scenario "and wants their profile to be visible" do
      fill_in "individual[date_of_birth]", with: "12/09/1990"
      fill_in "individual[current_job]", with: "Some job"
      fill_in "individual[description]", with: "Some info about me"
      fill_in "individual[reasons_to_join]", with: "Because"

      click_button "Valider mon profil"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
      @individual.reload
      expect(@individual.is_displayed).to be true
      expect(@individual.first_name).to eq("Jane")
      expect(@individual.last_name).to eq("Doe")
      expect(@individual.date_of_birth).to eq(Date.parse("12/09/1990"))
      expect(@individual.current_job).to eq("Some job")
      expect(@individual.description).to eq("Some info about me")
      expect(@individual.reasons_to_join).to eq("Because")
    end

    scenario "and uploads their picture" do
      file_path = Rails.root.join("spec", "support", "assets", "picture-profile.jpg")

      attach_file(file_path)

      click_button "Valider mon profil"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
      expect(Individual.first.picture.attached?).to be true
    end

    scenario "and adds city and country" do
      select "France", from: "individual[country]", match: :first
      fill_in "individual[city]", with: "Saint Julien Molin Molette"

      click_button "Valider mon profil"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
      @individual.reload
      expect(@individual.country).to eq("FRA")
      expect(@individual.city).to eq("Saint Julien Molin Molette")
    end

    scenario "after finishing onboarding" do
      @user.update(pending: false)

      fill_in "individual[date_of_birth]", with: "12/09/1990"
      fill_in "individual[current_job]", with: "Some job"
      fill_in "individual[description]", with: "Some info about me"
      fill_in "individual[reasons_to_join]", with: "Because"

      click_button "Valider mon profil"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
      expect(page).to have_content(I18n.t("private_space.dashboard.profile_updated"))
      @individual.reload
      expect(@individual.is_displayed).to be true
      expect(@individual.date_of_birth).to eq(Date.parse("12/09/1990"))
      expect(@individual.current_job).to eq("Some job")
      expect(@individual.description).to eq("Some info about me")
      expect(@individual.reasons_to_join).to eq("Because")
    end
  end

  context "at employer step" do
    before(:each) do
      search_call_url = "https://api.opencorporates.com/v0.4/companies/search"
      search_call_response_body = File.open(Rails.root.join("spec/mocks/open_corporates/search_mock.json")).read
      stub_request(:get, /#{Regexp.quote(search_call_url)}/).to_return(status: 200, body: search_call_response_body)
    end

    scenario "and add a company present in DB as their employer", js: true do
      company = FactoryBot.create(:company, name: "Nada")

      fill_in "individual[company_name]", with: "Nada"
      find("input.Button.Button--inline.Button--box").click
      find("h2", text: "Nada").click

      expect(page).to have_content("Ton entreprise actuelle")
      expect(current_path).to eq(user_profile_path(locale: :fr))
      expect(Individual.first.employer).to eq(company)
      expect(Company.last.creator).not_to eq @user
    end

    scenario "and add a company from open corporate API as their employer", js: true do
      fill_in "individual[company_name]", with: "France Télévision"
      find("input.Button.Button--inline.Button--box").click
      find("h2", text: "France Television", match: :first).click

      expect(page).to have_content("Ton entreprise actuelle")
      expect(current_path).to eq(user_profile_path(locale: :fr))
      expect(Company.count).to eq(1)
      expect(Individual.first.employer.name).to eq("France Television Publicite Conseil")
      expect(Company.last.creator).not_to eq @user
      expect(Company.last.attributes.except("id", "created_at", "updated_at", "admin_id", "public_slug")).to eq(
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

    scenario "and removes their employer", js: true do
      company = FactoryBot.create(:company, name: "Nada")
      @individual.update(employer: company)
      visit current_path

      expect(page).to have_css("h2", text: "Nada")
      within ".CompanyInfoCard" do
        click_link "Supprimer"
      end

      expect(page).to have_content("Rechercher le nom exact")
      expect(current_path).to eq(user_profile_path(locale: :fr))
      expect(Individual.first.employer).to be nil
    end

    scenario "and add a new employer", js: true do
      fill_in "individual[company_name]", with: "Nada"
      find("input.Button.Button--inline.Button--box").click
      click_link "Ajouter une entreprise"
      fill_in "individual[employer_attributes][name]", with: "Nada"
      fill_in "individual[employer_attributes][address]", with: "Lyon"
      click_button "Valider"
      click_button "Valider mon profil"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
      expect(Individual.first.employer.name).to eq("Nada")
      expect(Individual.first.employer.address).to eq("Lyon")
      expect(Company.last.creator).to eq @user
    end

    scenario "and edit their employer if they created it before", js: true do
      company = FactoryBot.create(:company, name: "Nada", creator: @user)
      @individual.update(employer: company)
      visit current_path

      expect(page).to have_css("h2", text: "Nada")
      within ".CompanyInfoCard" do
        click_button "Modifier les informations"
      end
      fill_in "individual[employer_attributes][name]", with: "Nada 2"
      click_button "Valider"
      click_button "Valider mon profil"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
      expect(Individual.first.employer.name).to eq("Nada 2")
      expect(Company.all.count).to eq 1
    end

    scenario "and edit their employer if they just created it", js: true do
      fill_in "individual[company_name]", with: "Nada"
      find("input.Button.Button--inline.Button--box").click
      click_link "Ajouter une entreprise"
      fill_in "individual[employer_attributes][name]", with: "Nada"
      fill_in "individual[employer_attributes][address]", with: "Lyon"
      click_button "Valider"

      expect(page).to have_content("Modifier les informations")
      expect(current_path).to eq(user_profile_path(locale: :fr))
    end

    scenario "and can cancel editing their employer", js: true do
      company = FactoryBot.create(:company, name: "Nada", creator: @user)
      @individual.update(employer: company)
      visit current_path

      expect(page).to have_css("h2", text: "Nada")
      within ".CompanyInfoCard" do
        click_button "Modifier les informations"
      end
      fill_in "individual[employer_attributes][name]", with: "Nada 2"
      click_button "Annuler"
      click_button "Valider mon profil"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
      expect(Individual.first.employer.name).to eq("Nada")
      expect(Company.all.count).to eq 1
    end

    scenario "and can't edit their employer if they didn't created it before", js: true do
      company = FactoryBot.create(:company, name: "Nada")
      @individual.update(employer: company)
      visit current_path

      expect(page).to have_css("h2", text: "Nada")
      expect(page).not_to have_content("Modifier les informations")
    end

    scenario "and can't edit their employer if it has an admin", js: true do
      company = FactoryBot.create(:company, :with_admin, name: "Nada", creator: @user)
      @individual.update(employer: company)
      visit current_path

      expect(page).to have_css("h2", text: "Nada")
      expect(page).not_to have_content("Modifier les informations")
    end

    scenario "and can edit their company, cancel a second edition, and still have the first edition saved", js: true do
      company = FactoryBot.create(:company, name: "Nada", creator: @user)
      @individual.update(employer: company)
      visit current_path

      expect(page).to have_css("h2", text: "Nada")
      within ".CompanyInfoCard" do
        click_button "Modifier les informations"
      end
      fill_in "individual[employer_attributes][name]", with: "Nada 2"
      click_button "Valider"
      within ".CompanyInfoCard" do
        click_button "Modifier les informations"
      end
      fill_in "individual[employer_attributes][name]", with: "Nada 3"
      click_button "Annuler"
      click_button "Valider mon profil"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
      expect(Individual.first.employer.name).to eq("Nada 2")
      expect(Company.all.count).to eq 1
    end

    scenario "and can select a company they created, then edit it" do
      # TODO compléter ce test
    end
  end
end
