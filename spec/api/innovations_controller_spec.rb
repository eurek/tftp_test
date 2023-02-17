require "rails_helper"

RSpec.describe Api::InnovationsController, type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  let(:headers) do
    {
      "HTTP_AUTHORIZATION": Rails.application.credentials.dig(:external_api_secret)
    }
  end

  let(:evaluator_1) { FactoryBot.create(:individual) }
  let(:evaluator_2) { FactoryBot.create(:individual) }
  let(:webhook_params) do
    {
      innovation: {
        external_uid: "some_uid",
        name: "AREDOX",
        short_description: "La solution pour l'énergie électrique renouvelable",
        problem_solved: "L'innovation concerne principalement le stockage de l'électricité.",
        solution_explained: "Par des réacteurs électrochimiques simples sans métaux rares.",
        potential_clients: "Les particuliers et les industriels",
        differentiating_elements: "les coûts, la sécurité",
        picture: "https://dummyimage.com/30x30/000/fff",
        status: "received",
        submitted_at: "2021-02-03T11:09:00.000Z",
        evaluations_amount: 19,
        city: "Bordeaux",
        country: "France",
        rating: 4,
        language: "FR",
        website: "https://www.aredox.com",
        action_lever: "zero_emissions",
        action_domain: "energy",
        selection_period: "S01E04",
        founders: ["Gérard Bienvenu", "Other Guy"],
        email_evaluators: [evaluator_1.email, evaluator_2.email]
      }
    }
  end
  let(:json_keys) do
    %w[id external_uid name city country status differentiating_elements_i18n evaluations_amount language
       potential_clients_i18n problem_solved_i18n rating short_description_i18n solution_explained_i18n website
       submitted_at created_at updated_at action_domain_id action_lever_id founders selection_period
       displayed_on_home submission_episode_id]
  end
  let!(:action_domain) { FactoryBot.create(:action_domain, title: "energy", name_i18n: {fr: "Energie", en: "Energy"}) }
  let!(:action_lever) do
    FactoryBot.create(:action_lever, title: "zero_emissions", name_i18n: {fr: "Zéro émission", en: "Zero emissions"})
  end

  it "returns 401 if secret is not as expected" do
    post api_innovations_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

    expect(response.status).to eq(401)
  end

  it "creates a new innovation if the innovation doesn't exist" do
    post api_innovations_path, params: webhook_params, headers: headers
    expect(response.status).to eq 200
    expect(response_json).to contain_keys json_keys

    expect(Innovation.count).to eq(1)
    innovation = Innovation.first
    webhook_params[:innovation].except(
      :picture, :language, :action_lever, :action_domain, :submitted_at, :country, :email_evaluators
    ).each do |key, value|
      expect(innovation.send(key)).to eq(value)
    end
    expect(innovation.picture.attached?).to eq true
    expect(innovation.country).to eq("FRA")
    expect(innovation.submitted_at).to eq Date.parse("2021-02-03")
    expect(innovation.language).to eq "fr"
    expect(innovation.action_domain).to eq action_domain
    expect(innovation.action_lever).to eq action_lever
    expect(innovation.evaluators).to include(evaluator_1, evaluator_2)
  end

  it "updates an existing innovation if it already exists" do
    image = Rails.root.join("spec", "support", "assets", "picture-profile.jpg")
    innovation = FactoryBot.create(:innovation,
      external_uid: webhook_params[:innovation][:external_uid],
      picture: fixture_file_upload(image))

    params = webhook_params
    params[:innovation][:picture] = nil

    expect {
      post api_innovations_path, params: params, headers: headers
    }.not_to change {
      Innovation.count
    }

    expect(response.status).to eq 200
    expect(response_json).to contain_keys json_keys

    innovation.reload
    webhook_params[:innovation].except(
      :picture, :language, :action_lever, :action_domain, :submitted_at, :country, :email_evaluators
    ).each do |key, value|
      expect(innovation.send(key)).to eq(value)
    end
    expect(innovation.picture.attached?).to eq false
  end
end
