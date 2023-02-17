require "rails_helper"

feature "user accesses episodes" do
  before(:each) do
    FactoryBot.create(:episode, season_number: 0, number: 1)
    FactoryBot.create(:episode, season_number: 1, number: 1)
  end

  scenario "by going to the page of one episode" do
    visit episode_path(id: Episode.first.id, locale: :fr)

    expect(page).to have_content("Les épisodes de Time for the Planet")
    expect(page).to have_content("Saison 0")
    expect(page).to have_content("Episode 1")
  end

  scenario "and can go to another episode", js: true do
    visit episode_path(id: Episode.first.id, locale: :fr)
    find("span", text: "Saison 1").click

    expect(page).to have_content("Les épisodes de Time for the Planet")
    expect(page).to have_content("Saison 1")
    expect(page).to have_content("Episode 1")
    expect(current_path).to eq episode_path(id: Episode.second.id, locale: :fr)
  end
end
