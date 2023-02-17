require "rails_helper"

RSpec.describe Api::InnovationsController, type: :request do
  let(:headers) do
    {
      "HTTP_AUTHORIZATION": Rails.application.credentials.dig(:external_api_secret)
    }
  end

  let(:team_member_1) { FactoryBot.create(:individual) }
  let(:team_member_2) { FactoryBot.create(:individual) }

  let(:webhook_params) do
    {
      innovation: {
        external_uid: "some_innovation_uid",
        funded_at: "2021-04-01",
        company_created_at: "2021-10-31",
        amount_invested: 1000,
        summary: "Changer notre ADN pour faire de la photosynthèse",
        scientific_committee_opinion: "Difficilement faisable avec les moyens à notre disposition",
        video_link: "https://www.plante-woman.fr/photosynthese",
        pitch_deck_link: "https://www.plante-woman.fr/pitch",
        carbon_potential: "Des millions de tonnes de GES par an",
        team_members: [team_member_1.email, team_member_2.email],
        pictures: %w[
          https://dummyimage.com/30x30/000/fff
          https://dummyimage.com/30x30/000/eeeeee
          https://dummyimage.com/30x30/000/dddddd
        ]
      }
    }
  end
  let(:json_keys) do
    %w[id funded_at company_created_at amount_invested video_link pitch_deck_link_i18n summary_i18n
       scientific_committee_opinion_i18n carbon_potential_i18n website development_stage innovation_id
       funding_episode_id created_at updated_at co2_reduction]
  end

  it "returns 401 if secret is not as expected" do
    post api_funded_innovations_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

    expect(response.status).to eq(401)
  end

  it "reports error if innovation is missing" do
    post api_funded_innovations_path, params: webhook_params, headers: headers
    expect(response.status).to eq 404
  end

  it "attaches a new funded_innovation to the innovation if it exists" do
    FactoryBot.create(:innovation, external_uid: webhook_params[:innovation][:external_uid])

    post api_funded_innovations_path, params: webhook_params, headers: headers
    expect(response.status).to eq 200
    expect(response_json).to contain_keys json_keys

    expect(FundedInnovation.count).to eq(1)
    funded_innovation = FundedInnovation.first
    webhook_params[:innovation]
      .except(:external_uid, :funded_at, :company_created_at, :pictures, :team_members).each do |key, value|
      expect(funded_innovation.send(key)).to eq(value)
    end
    expect(funded_innovation.funded_at).to eq(Date.parse(webhook_params[:innovation][:funded_at]))
    expect(funded_innovation.company_created_at).to eq(Date.parse(webhook_params[:innovation][:company_created_at]))
    expect(funded_innovation.pictures.attachments.count).to eq 3
    expect(funded_innovation.team_members).to include(team_member_1, team_member_2)
  end

  it "updates funded_innovation when it already exists" do
    innovation = FactoryBot.create(:innovation, external_uid: webhook_params[:innovation][:external_uid])
    funded_innovation = FactoryBot.create(:funded_innovation, innovation: innovation)

    post api_funded_innovations_path, params: webhook_params, headers: headers
    expect(response.status).to eq 200
    expect(response_json).to contain_keys json_keys

    expect(FundedInnovation.count).to eq(1)
    expect(funded_innovation.reload.funded_at).to eq(Date.parse(webhook_params[:innovation][:funded_at]))
    expect(funded_innovation.company_created_at).to eq(Date.parse(webhook_params[:innovation][:company_created_at]))
    webhook_params[:innovation]
      .except(:external_uid, :funded_at, :company_created_at, :pictures, :team_members).each do |key, value|
      expect(funded_innovation.send(key)).to eq(value)
    end
  end
end
