require "rails_helper"

RSpec.describe Api::BadgesController, type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  describe "update" do
    it "returns 401 if secret is not as expected" do
      post api_badges_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    let(:headers) do
      {
        "HTTP_AUTHORIZATION": Rails.application.credentials.dig(:external_api_secret)
      }
    end

    let(:webhook_params) do
      {
        badge: {
          external_uid: "id",
          name: "Nom",
          description: "Description",
          fun_description: "Slogan",
          position: 10,
          picture_light: "https://dummyimage.com/30x30/000/fff",
          picture_dark: nil,
          category: "financial"
        }
      }
    end

    let(:json_keys) do
      %w[id external_uid name_i18n description_i18n fun_description_i18n position created_at updated_at category]
    end

    it "creates a new badge if it doesn't exist" do
      expect {
        post api_badges_path, params: webhook_params, headers: headers
      }.to change {
        Badge.count
      }.by 1

      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys

      badge = Badge.first
      webhook_params[:badge].except!(:picture_light, :picture_dark).each do |key, value|
        expect(badge.send(key)).to eq(value)
      end
      expect(badge.picture_light.attached?).to eq true
      expect(badge.picture_dark.attached?).to eq false
    end

    it "updates an existing badge if it already exists" do
      image = Rails.root.join("spec", "support", "assets", "picture-profile.jpg")
      badge = create(:badge,
        external_uid: webhook_params[:badge][:external_uid],
        picture_light: fixture_file_upload(image))

      params = webhook_params
      params[:badge][:picture_dark] = params[:badge][:picture_light]
      params[:badge][:picture_light] = nil

      expect {
        post api_badges_path, params: params, headers: headers
      }.not_to change {
        Badge.count
      }

      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys

      badge.reload
      params[:badge].except!(:picture_light, :picture_dark).each do |key, value|
        expect(badge.send(key)).to eq(value)
      end
      expect(badge.picture_light.attached?).to eq false
      expect(badge.picture_dark.attached?).to eq true
    end

    it "updates the french version even if call is made with en locale" do
      badge = create(:badge, external_uid: webhook_params[:badge][:external_uid])
      params = webhook_params

      expect {
        post api_badges_path(locale: :en), params: params, headers: headers
      }.not_to change {
        Badge.count
      }

      expect(response.status).to eq 200

      badge.reload
      I18n.locale = :fr
      params[:badge].except!(:picture_light, :picture_dark).each do |key, value|
        expect(badge.send(key)).to eq(value)
      end
      I18n.locale = :en
      [:name, :description, :fun_description].each do |key|
        expect(badge.send(key, fallback: false)).to be nil
      end
    end
  end
end
