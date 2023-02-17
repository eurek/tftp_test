require "rails_helper"

describe "UsersController" do
  describe "dashboard" do
    before(:each) do
      @user = FactoryBot.create(:user, pending: true)
      sign_in_as(@user)
    end

    it "redirects to user profile if user is pending" do
      get user_dashboard_path(locale: :fr)

      expect(response.status).to eq 302
      expect(response).to redirect_to(user_profile_path(locale: :fr))
    end
  end
end
