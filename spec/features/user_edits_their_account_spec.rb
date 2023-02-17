require "rails_helper"

feature "user edits their account" do
  before(:each) do
    @user = FactoryBot.create(:user, pending: false)
    login_as(@user, scope: :user)
    visit edit_user_registration_path(locale: :fr)
  end

  context "successfully" do
    scenario "for email" do
      fill_in "user[individual_attributes][email]", with: "new_email@email.com"
      fill_in "user[current_password]", with: @user.password
      click_button "Modifier"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
      expect(page).to have_content("Ton compte a bien été modifié.")
      expect(@user.reload.email).to eq("new_email@email.com")
    end

    scenario "for password" do
      fill_in "user[individual_attributes][email]", with: @user.email
      fill_in "user[password]", with: "new_password"
      fill_in "user[password_confirmation]", with: "new_password"
      fill_in "user[current_password]", with: @user.password
      click_button "Modifier"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
      expect(page).to have_content("Ton compte a bien été modifié.")
      expect(@user.reload.valid_password?("new_password")).to be true
    end

    scenario "can add a picture", js: true do
      visit user_profile_path(locale: :fr)

      expect(page).not_to have_content "Modifier"

      file_path = Rails.root.join("spec", "support", "assets", "picture-profile.jpg")
      attach_file("individual_picture", file_path, visible: false)

      expect(page).to have_content "picture-profile.jpg"
      expect(page).to have_content "Modifier"

      click_on "Valider mon profil"

      visit user_profile_path(locale: :fr)

      expect(page).to have_content "picture-profile.jpg"
    end

    scenario "can remove a picture", js: true do
      @user.individual.picture.attach(
        io: File.open(Rails.root.join("spec/support/assets/picture-profile.jpg")),
        filename: "picture-profile.jpg"
      )
      @user.individual.save!

      visit user_profile_path(locale: :fr)

      expect(page).to have_content "picture-profile.jpg"
      expect(page).to have_content "Supprimer"
      expect(@user.individual.picture.attached?).to eq true

      click_on "Supprimer"

      @user.reload

      expect(page).not_to have_content "picture-profile.jpg"
      expect(page).not_to have_content "Supprimer"
      within ".Flash" do
        expect(page).to have_content "Votre fichier a bien été supprimé."
      end
      expect(@user.individual.picture.attached?).to eq false
    end
  end

  context "unsuccessfully" do
    scenario "because email is missing" do
      fill_in "user[individual_attributes][email]", with: ""
      fill_in "user[password]", with: "new_password"
      fill_in "user[password_confirmation]", with: "new_password"
      fill_in "user[current_password]", with: @user.password
      click_button "Modifier"

      expect(current_path).to eq(user_registration_path(locale: :fr))
      expect(page).to have_content("Merci d'indiquer ton email")
    end

    scenario "because current password is missing" do
      fill_in "user[individual_attributes][email]", with: "new_email@email.com"
      fill_in "user[password]", with: "new_password"
      fill_in "user[password_confirmation]", with: "new_password"
      click_button "Modifier"

      expect(current_path).to eq(user_registration_path(locale: :fr))
      expect(page).to have_content("Merci d'indiquer Mot de passe actuel")
    end

    scenario "because password confirmation is missing" do
      fill_in "user[individual_attributes][email]", with: "new_email@email.com"
      fill_in "user[password]", with: "new_password"
      fill_in "user[current_password]", with: @user.password
      click_button "Modifier"

      expect(current_path).to eq(user_registration_path(locale: :fr))
      expect(page).to have_content("ne concorde pas avec ton nouveau mot de passe")
    end

    scenario "because password confirmation is different" do
      fill_in "user[individual_attributes][email]", with: "new_email@email.com"
      fill_in "user[password]", with: "new_password"
      fill_in "user[password_confirmation]", with: "wrong_password"
      fill_in "user[current_password]", with: @user.password
      click_button "Modifier"

      expect(current_path).to eq(user_registration_path(locale: :fr))
      expect(page).to have_content("ne concorde pas avec ton nouveau mot de passe")
    end
  end

  scenario "and can delete it" do
    click_link "Supprimer mon compte"

    expect(current_path).to eq(root_path(locale: :fr))
    expect(page).to have_content("Votre compte a bien été supprimé.")
    expect { @user.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
