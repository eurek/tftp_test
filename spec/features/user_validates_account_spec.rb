require "rails_helper"

feature "user validate account" do
  let!(:user) { FactoryBot.create(:user, confirmed_at: nil, password: nil) }

  context "successfully" do
    scenario "by clicking on link to access confirmation screen" do
      open_email(user.individual.email)

      current_email.click_link "en cliquant sur ce lien"

      expect(current_path).to eq(user_confirmation_path(locale: :fr))
      expect(page).to have_content("Active ton espace actionnaire")
    end

    scenario "by choosing his/her password" do
      open_email(user.individual.email)
      current_email.click_link "en cliquant sur ce lien"

      fill_in "user[password]", with: "new_password"
      fill_in "user[password_confirmation]", with: "new_password"
      click_button "Activer mon espace"

      expect(current_path).to eq(user_profile_path(locale: :fr))
      expect(page).to have_content("Ton compte a bien été confirmé.")
      expect(user.reload.valid_password?("new_password")).to eq true
    end
  end

  context "unsuccessfully" do
    scenario "because password and password confirmation do not match" do
      open_email(user.individual.email)
      current_email.click_link "en cliquant sur ce lien"

      fill_in "user[password]", with: "new_password"
      fill_in "user[password_confirmation]", with: "wrong_password"
      click_button "Activer mon espace"

      expect(current_path).to eq(user_confirmation_path(locale: :fr))
      expect(page).to have_content("Confirmation du nouveau mot de passe ne concorde pas avec ton nouveau mot de passe")
    end
  end
end
