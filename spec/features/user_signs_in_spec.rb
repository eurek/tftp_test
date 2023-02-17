require "rails_helper"

feature "user signs in" do
  scenario "using link in navbar" do
    visit root_path({locale: "fr"})

    find("a.Navbar-linkDesktop", text: I18n.t("common.login")).click

    expect(current_path).to eq(connection_path(locale: :fr))
  end

  scenario "and can access either private space or galaxy" do
    visit root_path({locale: "fr"})

    find("a.Navbar-linkDesktop", text: I18n.t("common.login")).click

    expect(page).to have_link(I18n.t("connection.private_space.cta"))
    expect(page).to have_link(I18n.t("connection.galaxy.cta"))
  end

  scenario "already signed in user access dashboard using link in navbar" do
    @user = FactoryBot.create(:user, pending: false)
    login_as(@user, scope: :user)
    visit root_path({locale: "fr"})

    find("a.Navbar-linkDesktop", text: I18n.t("common.login")).click
    find("a.Button", text: I18n.t("connection.private_space.cta")).click

    expect(current_path).to eq(user_dashboard_path(locale: :fr))
  end

  context "when accessing the page" do
    scenario "user sees password hint if pending param is present" do
      visit new_user_session_path(locale: :fr, pending: "true")

      expect(page).to have_content("Reçu dans l'email de confirmation")
    end

    scenario "user doesn't see password hint if pending param is not present" do
      visit new_user_session_path(locale: :fr)

      expect(page).not_to have_content("Reçu dans l'email de confirmation")
    end
  end

  context "successfully" do
    scenario "pending user signs in and is redirected to onboarding" do
      user = FactoryBot.create(:user, pending: true)

      visit new_user_session_path(locale: :fr)
      fill_in "user[email]", with: user.email
      fill_in "user[password]", with: user.password
      click_button "Me connecter"

      expect(current_path).to eq(user_profile_path(locale: :fr))
      expect(page).to have_content("Tu es maintenant connecté•e à ton espace actionnaire.")
    end

    scenario "not pending user signs in and is redirected to dashboard" do
      user = FactoryBot.create(:user, pending: false)

      visit new_user_session_path(locale: :fr)
      fill_in "user[email]", with: user.email
      fill_in "user[password]", with: user.password
      click_button "Me connecter"

      expect(current_path).to eq(user_dashboard_path(locale: :fr))
      expect(page).to have_content("Tu es maintenant connecté•e à ton espace actionnaire.")
    end
  end

  context "unsuccessfully" do
    scenario "because email and password are missing" do
      visit new_user_session_path(locale: :fr)
      click_button "Me connecter"

      expect(current_path).to eq(new_user_session_path(locale: :fr))
      expect(page).to have_content("Ton email ou mot de passe est incorrect.")
    end

    scenario "because password is missing" do
      user = FactoryBot.create(:user)

      visit new_user_session_path(locale: :fr)
      fill_in "user[email]", with: user.email
      click_button "Me connecter"

      expect(current_path).to eq(new_user_session_path(locale: :fr))
      expect(page).to have_content("Ton email ou mot de passe est incorrect.")
    end

    scenario "because email is missing" do
      user = FactoryBot.create(:user)

      visit new_user_session_path(locale: :fr)
      fill_in "user[password]", with: user.password
      click_button "Me connecter"

      expect(current_path).to eq(new_user_session_path(locale: :fr))
      expect(page).to have_content("Ton email ou mot de passe est incorrect.")
    end
  end
end
