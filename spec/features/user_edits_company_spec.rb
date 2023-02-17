require "rails_helper"

feature "user edits company" do
  before(:each) do
    @user = FactoryBot.create(:user)
    @company = FactoryBot.create(:company)
    @shares_purchase = FactoryBot.create(:shares_purchase, individual: @user.individual,
      company_info: {name: @company.name})
    login_as(@user, scope: :user)
  end

  context "unsuccessfully" do
    scenario "because name is missing" do
      @company.update!(admin: @user)
      visit edit_company_path(locale: :fr, id: @company.id, shares_purchase_id: @shares_purchase.id)
      fill_in "company[name]", with: ""
      click_button "Valider mon entreprise"

      expect(current_path).to eq(update_company_path(locale: :fr, id: @company.id))
      expect(page).to have_content("Merci d'indiquer nom de l'entreprise")
    end

    scenario "because image format is not correct" do
      @company.update!(admin: @user)
      file_path = Rails.root.join("spec", "support", "assets", "profile.heif")
      visit edit_company_path(locale: :fr, id: @company.id, shares_purchase_id: @shares_purchase.id)

      attach_file("company[logo]", file_path, visible: false)
      click_button "Valider mon entreprise"

      expect(page).to have_content("logo doit être au format jpg, jpeg ou png")
    end

    scenario "because user wasn't the admin" do
      @company.admin = FactoryBot.create(:user)

      visit edit_company_path(locale: :fr, id: @company.id, shares_purchase_id: @shares_purchase.id)

      expect(current_path).to eq(shares_purchases_path(locale: :fr))
    end
  end

  context "successfully" do
    scenario "with all given information" do
      @company.update!(admin: @user)

      visit edit_company_path(locale: :fr, id: @company.id, shares_purchase_id: @shares_purchase.id)
      fill_in "company[name]", with: "My Company"
      fill_in "company[address]", with: "Street, City"
      fill_in "company[description]", with: "Description"
      fill_in "company[co2_emissions_reduction_actions]", with: "Some things I guess?"
      fill_in "company[website]", with: "https://mywebsite.com"
      fill_in "company[facebook]", with: "https://facebook.com/pg/some_page"
      fill_in "company[linkedin]", with: "https://linkedin.com/29879820O2"

      click_button "Valider mon entreprise"

      expect(page).to have_content("Les informations sur ton entreprise ont bien été mises à jour.")
      expect(current_path).to eq(shares_purchases_path(locale: :fr))
      @company.reload

      expect(@company.name).to eq "My Company"
      expect(@company.address).to eq "Street, City"
      expect(@company.description).to eq "Description"
      expect(@company.co2_emissions_reduction_actions).to eq "Some things I guess?"
      expect(@company.website).to eq "https://mywebsite.com"
      expect(@company.facebook).to eq "https://facebook.com/pg/some_page"
      expect(@company.linkedin).to eq "https://linkedin.com/29879820O2"
    end

    scenario "with a logo", js: true do
      @company.update!(admin: @user)

      visit edit_company_path(locale: :fr, id: @company.id, shares_purchase_id: @shares_purchase.id)

      expect(page).not_to have_content("Modifier")

      file_path = Rails.root.join("spec", "support", "assets", "logo-time-planet.png")
      attach_file("company[logo]", file_path, visible: false)

      expect(page).to have_content("logo-time-planet.png")
      expect(page).to have_content("Modifier")

      click_button "Valider mon entreprise"

      expect(page).to have_content("Les informations sur ton entreprise ont bien été mises à jour.")
      expect(current_path).to eq(shares_purchases_path(locale: :fr))
      expect(@company.reload.logo.attached?).to be true
      expect(@company.reload.logo.filename.to_s).to eq "logo-time-planet.png"
    end

    scenario "can remove logo", js: true do
      @company.update(admin: @user)
      @company.logo.attach(
        io: File.open(Rails.root.join("spec/support/assets/picture-profile.jpg")),
        filename: "logo-time-planet.jpg"
      )
      @company.save!

      visit edit_company_path(locale: :fr, id: @company.id, shares_purchase_id: @shares_purchase.id)

      expect(page).to have_content "logo-time-planet.jpg"
      expect(page).to have_content "Supprimer"

      click_on "Supprimer"
      @company.reload

      expect(page).not_to have_content "logo-time-planet.jpg"
      expect(page).not_to have_content "Supprimer"
      within ".Flash" do
        expect(page).to have_content "Votre fichier a bien été supprimé."
      end
      expect(@company.logo.attached?).to eq false
    end
  end
end
