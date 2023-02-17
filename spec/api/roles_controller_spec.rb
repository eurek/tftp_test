require "rails_helper"

RSpec.describe Api::RolesController, type: :request do
  describe "create" do
    it "returns 401 if secret is not as expected" do
      post api_roles_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    let(:headers) do
      {
        "HTTP_AUTHORIZATION": Rails.application.credentials.dig(:external_api_secret)
      }
    end

    let(:params) do
      {
        role: {
          external_uid: "id",
          name: "Nom",
          description: "Description",
          position: 2,
          attributable_to: "all"
        }
      }
    end

    let(:json_keys) do
      %w[id external_uid created_at updated_at position attributable_to name_i18n description_i18n]
    end

    it "creates a new role if it doesn't exist" do
      expect {
        post api_roles_path, params: params, headers: headers
      }.to change {
        Role.count
      }.by 1
      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys

      role = Role.first
      params[:role].each do |key, value|
        expect(role.send(key)).to eq(value)
      end
    end

    it "updates an existing badge if it already exists" do
      role = FactoryBot.create(:role, external_uid: params[:role][:external_uid], name: "Test", description: nil)
      expect {
        post api_roles_path, params: params, headers: headers
      }.not_to change {
        Role.count
      }
      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys

      role.reload
      params[:role].each do |key, value|
        expect(role.send(key)).to eq(value)
      end
    end

    it "updates the french version even if call is made with en locale" do
      role = FactoryBot.create(:role, external_uid: params[:role][:external_uid])

      expect {
        post api_roles_path(locale: :en), params: params, headers: headers
      }.not_to change {
        Role.count
      }

      expect(response.status).to eq 200

      role.reload
      I18n.locale = :fr
      params[:role].each do |key, value|
        expect(role.send(key)).to eq(value)
      end
      I18n.locale = :en
      [:name, :description].each do |key|
        expect(role.send(key, fallback: false)).to be nil
      end
    end
  end
end
