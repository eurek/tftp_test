require "rails_helper"

feature "users sees dashboard" do
  before(:each) do
    @user = FactoryBot.create(:user, pending: false)
    login_as(@user, scope: :user)
  end

  scenario "when accessing page" do
    visit user_dashboard_path(locale: :fr)

    expect(page).to have_content("Bonjour, Jane.")
  end

  scenario "and can log out", js: true do
    visit user_dashboard_path(locale: :fr)
    find("i", text: "power_settings_new").click

    expect(current_path).to eq(root_path(locale: :fr))
    expect(page).to have_content("Tu es bien déconnecté•e de ton espace actionnaire.")
  end

  scenario "can not see refund link to buy new shares if user does not have one" do
    visit user_dashboard_path(locale: :fr)

    expect(page).not_to have_link("Investir de nouveau", href: /https:\/\/www.typeform.com/)
  end

  scenario "can see his completion rate" do
    visit user_dashboard_path(locale: :fr)

    expect(page).to have_content("Ton profil actionnaire est rempli à\n30 %")
  end

  scenario "can navigate to edit profile page" do
    visit user_dashboard_path(locale: :fr)

    within ".CompletionPanel-shareholder" do
      click_on "Modifier mon profil"
    end

    expect(current_path).to eq(user_profile_path(locale: :fr))
  end

  scenario "can click on Voir mon profile and see his user show page" do
    visit user_dashboard_path(locale: :fr)

    click_on "Voir mon profil actionnaire"

    expect(current_path).to eq(shareholder_individual_show_path(@user.individual, locale: :fr))
  end

  scenario "can click on roadmap link" do
    visit user_dashboard_path(locale: :fr)

    click_on "Voir le plan d'action"

    expect(current_path).to eq(roadmap_tasks_path(locale: :fr))
  end
end
