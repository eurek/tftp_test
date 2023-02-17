require "rails_helper"

feature "user sees pages" do
  scenario "successfully on show" do
    my_page = FactoryBot.create(:page)

    visit page_path({slug: my_page.slug, locale: :fr})

    expect(page).to have_content(my_page.title)
    expect(page).to have_content(my_page.body)
  end
end
