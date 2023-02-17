require "rails_helper"

feature "user sees problem page" do
  scenario "successfully on index page" do
    visit problems_path({locale: :fr})

    expect(page).to have_content("Notre champs d'action")
  end

  scenario "successfully on show page" do
    problem = FactoryBot.create(:problem)
    img = File.open(Rails.root.join("app/assets/images/logo-time-planet.png"))
    problem.cover_image.attach(io: img, filename: "test.jpg")

    visit problem_path({locale: :fr, id: problem.id})

    expect(page).to have_content(problem.title)
  end

  scenario "successfully on show page even if description is not present" do
    problem = FactoryBot.create(:problem, description_i18n: {})
    img = File.open(Rails.root.join("app/assets/images/logo-time-planet.png"))
    problem.cover_image.attach(io: img, filename: "test.jpg")

    visit problem_path({locale: :fr, id: problem.id})

    expect(page).to have_content(problem.title)
  end
end
