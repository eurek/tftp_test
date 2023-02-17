require "rails_helper"

feature "admin can search in multiple models" do
  let!(:content) { create(:content, title: "Doe") }
  let!(:admin) { create(:admin_user) }
  let!(:individual) {
    create(:individual, first_name: "John", last_name: "Doe", current_job: "Jeanne Doe incorporation")
  }
  let!(:tag) { create(:tag, name: "Doe") }

  before do
    login_as(admin)
    visit admin_search_path(locale: :fr)
  end

  scenario "can search in multiple models" do
    fill_in "query", with: "Doe"
    click_on "Find"

    within "tbody" do
      expect(page.all("tr").count).to eq(3)
      expect(page).to have_content "Individual"
      expect(page).to have_content "Content"
      expect(page).to have_content "Tag"
    end
  end

  scenario "can access to show page of a result" do
    fill_in "query", with: "John"
    click_on "Find"

    within "tbody" do
      expect(page.all("tr").count).to eq(1)
      click_on "Show"
    end

    expect(current_path).to eq admin_individual_path(:fr, individual.id)
  end

  scenario "can search every where in admin", js: true do
    visit admin_root_path(locale: :fr)

    fill_in "query", with: "Doe"
    click_on "Find"

    expect(current_path).to eq admin_search_path(:fr)
    within "tbody" do
      expect(page.all("tr").count).to eq(3)
      expect(page).to have_content "Individual"
      expect(page).to have_content "Content"
      expect(page).to have_content "Tag"
    end
  end
end
