require "rails_helper"

feature "user accesses events" do
  scenario "through the list of events" do
    visit events_path(locale: :fr)

    expect(page).to have_content("Évènements")
  end

  scenario "and can see one event" do
    event = FactoryBot.create(:event)
    visit events_path(locale: :fr)

    click_link event.title

    expect(current_path).to eq(event_path(id: event.id, locale: :fr))
    expect(page).to have_content(event.title.upcase_first)
  end
end
