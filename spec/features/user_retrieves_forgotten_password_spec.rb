require "rails_helper"

feature "user retrieves forgotten password" do
  scenario "user enters wrong email" do
    visit new_user_password_path(locale: :fr)

    fill_in "user[email]", with: "wrong email"
    click_button "Recevoir le lien"

    expect(current_path).to eq(user_password_path(locale: :fr))
    expect(page).to have_content("N’a pas été trouvé(e)")
  end

  scenario "user receives an email when entering email address" do
    user = FactoryBot.create(:user)
    visit new_user_password_path(locale: :fr)

    fill_in "user[email]", with: user.individual.email
    click_button "Recevoir le lien"

    expect(current_path).to eq(new_user_session_path(locale: :fr))
    expect(page).to have_content(
      "Tu vas recevoir sous quelques minutes un email t'indiquant comment réinitialiser ton mot de passe."
    )
    expect(Devise.mailer.deliveries.count).to eq(1)
    open_email(user.individual.email)
    expect(current_email).to have_content(user.individual.first_name)
  end

  scenario "user receives an email without first_name when admin_user" do
    user = FactoryBot.create(:admin_user)
    visit new_admin_user_password_path(locale: :en)

    fill_in "admin_user[email]", with: user.email
    click_button "Reset My Password"

    expect(current_path).to eq(new_admin_user_session_path(locale: :en))
    expect(Devise.mailer.deliveries.count).to eq(1)
  end

  scenario "user can click on link to access new password screen" do
    user = FactoryBot.create(:user)
    visit new_user_password_path(locale: :fr)

    fill_in "user[email]", with: user.email
    click_button "Recevoir le lien"
    open_email(user.email)
    current_email.click_link "Modifier mon mot de passe"

    expect(current_path).to eq(edit_user_password_path(locale: :fr))
    expect(page).to have_content("Ton nouveau mot de passe")
  end

  scenario "user can choose a new password" do
    user = FactoryBot.create(:user, pending: false)
    visit new_user_password_path(locale: :fr)

    fill_in "user[email]", with: user.email
    click_button "Recevoir le lien"
    open_email(user.email)
    current_email.click_link "Modifier mon mot de passe"
    fill_in "user[password]", with: "new_password"
    fill_in "user[password_confirmation]", with: "new_password"
    click_button "Modifier"

    expect(current_path).to eq(user_dashboard_path(locale: :fr))
    expect(page).to have_content("Ton mot de passe a bien été modifié. Tu es maintenant connecté·e.")
    expect(user.reload.valid_password?("new_password")).to eq true
  end
end
