require "rails_helper"

RSpec.describe Api::EventsController, type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  describe "update" do
    it "returns 401 if secret is not as expected" do
      post api_events_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    let(:headers) do
      {
        "HTTP_AUTHORIZATION": Rails.application.credentials.dig(:external_api_secret)
      }
    end

    let(:webhook_params) do
      {
        event: {
          external_uid: "id",
          title: "Titre de l'évènement",
          locale: "fr",
          description: "Description",
          date: "2021-02-08T11:09:00.000Z",
          timezone: "Europe/Paris",
          venue: "online",
          picture: "https://dummyimage.com/30x30/000/fff",
          registration_link: "https://www.eventbrite.fr/e/inscription-123456789",
          category: "course"
        }
      }
    end

    let(:json_keys) do
      %w[id external_uid title description locale date venue registration_link created_at updated_at category timezone]
    end

    it "creates a new event if it doesn't exist" do
      expect {
        post api_events_path, params: webhook_params, headers: headers
      }.to change {
        Event.count
      }.by 1

      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys

      event = Event.first
      webhook_params[:event].except!(:picture).each do |key, value|
        expect(event.send(key)).to eq(value)
      end
      expect(event.picture.attached?).to eq true
    end

    it "updates an existing event if it already exists" do
      image = Rails.root.join("spec", "support", "assets", "picture-profile.jpg")
      event = FactoryBot.create(:event,
        external_uid: webhook_params[:event][:external_uid],
        picture: fixture_file_upload(image))

      params = webhook_params
      params[:event][:picture] = nil

      expect {
        post api_events_path, params: params, headers: headers
      }.not_to change {
        Event.count
      }

      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys

      event.reload
      params[:event].except!(:picture).each do |key, value|
        expect(event.send(key)).to eq(value)
      end
      expect(event.picture.attached?).to eq false
    end
  end
end
