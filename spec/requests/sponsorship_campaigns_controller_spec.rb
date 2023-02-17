require "rails_helper"

describe "SponsorshipCampaignsController" do
  let!(:individual) { FactoryBot.create(:individual, :with_picture) }
  let(:user) { FactoryBot.create(:user, pending: false, individual: individual) }

  describe "dashboard" do
    it "user sees their sponsorship campaign dashboard in french" do
      sign_in_as(user)

      get sponsorship_campaign_dashboard_path(locale: :fr)

      campaign_link = ambassador_landing_url(ambassador_slug: individual.public_slug, locale: nil)
      expect(response.body.match?(/<input.*value="#{campaign_link}"/)).to be true
    end

    it "user sees their sponsorship campaign dashboard in another language" do
      sign_in_as(user)

      get sponsorship_campaign_dashboard_path(locale: :en)

      expect(response.status).to eq(200)
    end
  end

  describe "public_show" do
    def former_slug
      "#{user.id}-#{individual.first_name.parameterize}-#{individual.last_name.parameterize}"
    end

    it "matches new slug and redirects to home with relevant params" do
      get sponsorship_campaign_public_show_path(user, locale: :en)

      expect(response.status).to eq 301
      expect(response).to redirect_to("/en?utm_medium=ambassador&ambassador=#{individual.to_param}")
    end

    it "matches former slug and redirects to home with relevant params" do
      get sponsorship_campaign_public_show_path(id: former_slug, locale: :en)

      expect(response.status).to eq 301
      expect(response).to redirect_to("/en?utm_medium=ambassador&ambassador=#{individual.to_param}")
    end

    it "redirects to 404 is user is not found" do
      expect {
        get sponsorship_campaign_public_show_path(id: "wrong_id", locale: :en)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
