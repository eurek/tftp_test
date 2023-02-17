require "rails_helper"

feature "user sees home page" do
  scenario "and can switch language", js: true do
    FactoryBot.create(:translation,
      key: "home.mission.title",
      value: "Time for the Planet rassemble de l’argent pour détecter et déployer 100 innovations mondiales
        contre les gaz à effet de serre.")
    Mobility.with_locale(:en) do
      FactoryBot.create(:translation, key: "common.language", value: "english")
      Translation.find_by(key: "home.mission.title").update(
        value: "Time for the Planet is raising money to detect and deploy 100 global innovations
          against greenhouse gases."
      )
    end
    visit root_path({locale: :fr})

    expect(page).to have_content(
      "Time for the Planet rassemble de l’argent pour détecter et déployer 100 innovations mondiales"\
        " contre les gaz à effet de serre."
    )
    click_button "fr"
    click_link "english"

    expect(current_path).to eq(root_path(locale: :en))
    expect(page).to have_content("Time for the Planet is raising money to detect and deploy 100 global innovations"\
      " against greenhouse gases.")
  end

  scenario "has a custom image preview when i-joined parameter is true" do
    visit root_path({locale: :fr, "i-joined": true})

    expect(page.html.include?("meta name=\"image_preview\"")).to eq(true)
  end

  scenario "has the default image preview when i-joined parameter is false" do
    visit root_path({locale: :fr})

    expect(page.html.include?("meta name=\"image_preview\"")).to eq(false)
  end
end
