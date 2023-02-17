require "rails_helper"

feature "users sees badges and roles" do
  before(:each) do
    @individual = FactoryBot.create(:individual)
    @user = FactoryBot.create(:user, individual: @individual)
    @individual.badges = Array.new(5) { FactoryBot.create(:badge, category: "community_planet") }
    @individual.roles << FactoryBot.create(:role, :with_link_in_description)
    login_as(@user, scope: :user)
  end

  scenario "when accessing page" do
    visit user_badges_path(locale: :fr)

    expect(page).to have_content("Tes badges")
    expect(page).to have_content("Tes fonctions")
  end

  scenario "and badges are all displayed" do
    visit user_badges_path(locale: :fr)

    expect(page).to have_css(".BadgeList-badge", count: 5)
  end

  scenario "can see badge description in tooltip", js: true do
    badge = FactoryBot.create(:badge)
    @individual.badges << badge

    visit user_badges_path(locale: :fr)
    first(".BadgeList-badge").click

    expect(page).to have_content(badge.description)
  end

  scenario "can see badge description and click link in tooltip", js: true do
    @individual.badges = [FactoryBot.create(:badge, :with_link_in_description)]

    visit user_badges_path(locale: :fr)
    page.all(".BadgeList-badge").last.click
    first(".ShareholderAssetTooltip-description a").click

    expect(current_host).to eq("https://nada.computer")
  end

  scenario "can see badge category" do
    visit user_badges_path(locale: :fr)

    expect(page).to have_content(
      I18n.t("activerecord.attributes.badge.categories.#{@individual.badges.first.category}").capitalize
    )
    within ".BadgeList--communityPlanet" do
      expect(page).to have_css(".BadgeList-badge", count: 5)
    end
    expect(page).not_to have_content(
      I18n.t("activerecord.attributes.badge.categories.year").capitalize
    )
    expect(page).not_to have_css(".year")
  end

  scenario "can see role description in tooltip", js: true do
    role = FactoryBot.create(:role)
    @individual.roles << role
    visit user_badges_path(locale: :fr)

    first(".RolesList-role").click

    expect(page).to have_content(role.description)
  end

  scenario "can click on role description's link in tooltip" do
    visit user_badges_path(locale: :fr)

    first(".RolesList-role").click
    first(".ShareholderAssetTooltip a").click

    expect(current_host).to eq("https://nada.computer")
  end
end
