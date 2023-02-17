require "rails_helper"

feature "user deletes profile picture" do
  before(:each) do
    @user = FactoryBot.create(:user)
    login_as(@user, scope: :user)
  end

  scenario "successfully deletes profile picture" do
    @user.individual.picture.attach(
      io: File.open("spec/support/assets/picture-profile.jpg"), filename: "picture-profile.jpg"
    )
    visit user_profile_path(locale: :fr)

    click_link "Supprimer"

    expect(@user.reload.individual.picture.attached?).to be false
    expect(current_path).to eq(user_profile_path(locale: :fr))
    expect(page).to have_content(I18n.t("common.file_deleted"))
  end

  scenario "can't see delete button when no picture attached" do
    visit user_profile_path(locale: :fr)

    expect(page).to have_css("a.FileInput-editButton--hidden")
  end
end
