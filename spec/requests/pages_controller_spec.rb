require "rails_helper"

describe "Pages Controller" do
  describe "home" do
    let(:ambassador) { FactoryBot.create(:user) }

    scenario "displays successfully" do
      FactoryBot.create(:individual, :with_picture_and_shares_purchase)
      FactoryBot.create(:individual, :with_picture_and_shares_purchase)
      FactoryBot.create(:highlighted_content, associate_ids: Individual.last(2).pluck(:id))
      3.times do
        FactoryBot.create(:funded_innovation, :with_co2_reduction,
          innovation: FactoryBot.create(:innovation, :with_picture, displayed_on_home: "in_funded_section"))
      end
      3.times do
        FactoryBot.create(:innovation, :with_picture, displayed_on_home: "in_future_funding")
      end

      get root_path({locale: :fr})

      expect(response.status).to eq 200
    end

    it "increment ambassador generated visit when ambassador param is present" do
      ambassador = FactoryBot.create(:user, generated_visits: 0)

      get root_path({locale: :fr, ambassador: ambassador.individual.public_slug})

      expect(ambassador.reload.generated_visits).to eq(1)
      expect(AutopilotAmbassadorPusherJob).to have_received(:perform_later).with(ambassador.id)
    end

    it "it should not fail when ambassador public_slug does not exist" do
      get root_path({locale: :fr, ambassador: "fake_public_slug"})

      expect(response.status).to eq 200
      expect(response.body).to include(
        "Nous, citoyens du monde entier, ne sommes pas résignés face au changement climatique."
      )
    end
  end

  describe "ambassador landing" do
    it "should redirect to home with appropriate utms for influencers" do
      get ambassador_landing_path("poi.family", locale: :en)

      expect(response.status).to eq 302
      expect(response).to redirect_to(
        "/en?utm_source=instagram&utm_medium=social&utm_campaign=influenceur%20avril%202021&utm_content=poi.family"
      )
    end

    it "should redirect to home with appropriate params for shareholder ambassadors" do
      ambassador = FactoryBot.create(:user)
      get ambassador_landing_path(ambassador.individual.public_slug, locale: :en)

      expect(response.status).to eq 302
      expect(response).to redirect_to("/en?utm_medium=ambassador&ambassador=#{ambassador.individual.to_param}")
    end

    it "should redirect to 404 when influencer nor ambassador is found" do
      get ambassador_landing_path("wrong_slug", locale: :en)

      expect(response.status).to eq 302
      expect(response).to redirect_to("/en/404")
    end
  end
end
