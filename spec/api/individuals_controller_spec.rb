require "rails_helper"

RSpec.describe Api::IndividualsController, type: :request do
  let(:headers) do
    {
      "HTTP_AUTHORIZATION": Rails.application.credentials.dig(:external_api_secret)
    }
  end

  describe "create" do
    let(:json_keys) do
      %w[id external_uid current_job description reasons_to_join is_displayed created_at updated_at public_slug
         first_name last_name email phone date_of_birth address city zip_code country employer_id origin
         communication_language nationality department_number linkedin latitude longitude id_card_received
         is_100_club stacker_role funded_innovation_id locale username]
    end

    let(:params) do
      {
        individual: {
          email: "edith@piaf.fr",
          first_name: "Edith",
          last_name: "Piaf",
          date_of_birth: "27/11/1997",
          phone: "0033678543322",
          address: "1 rue du Chariot d'Or",
          zip_code: "69004",
          city: "Lyon",
          country: "FRA",
          communication_language: "fr",
          nationality: "Française",
          is_100_club: false,
          is_displayed: false,
          username: "edith_cuicui",
          stacker_role: "admin",
          origin: "linkedin",
          id_card_received: true
        }
      }
    end

    it "returns 401 if secret is not as expected" do
      post api_badges_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    it "creates a new individual if it doesn't exist" do
      post api_individuals_path, params: params, headers: headers

      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys

      expect(Individual.count).to eq(1)
      individual = Individual.last
      params[:individual].except(:date_of_birth, :origin).each do |key, value|
        expect(individual.send(key)).to eq(value)
      end
      expect(individual.date_of_birth).to eq Date.parse(params[:individual][:date_of_birth])
      expect(individual.origin).to eq([params[:individual][:origin]])
    end

    it "updates an existing individual if it already exists" do
      individual = FactoryBot.create(:individual, email: params[:individual][:email])

      post api_individuals_path, params: params, headers: headers

      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys
      expect(Individual.count).to eq(1)
      individual.reload
      params[:individual].except(:date_of_birth, :origin).each do |key, value|
        expect(individual.send(key)).to eq(value)
      end
      expect(individual.date_of_birth).to eq Date.parse(params[:individual][:date_of_birth])
      expect(individual.origin).to eq([params[:individual][:origin]])
    end
  end
end
