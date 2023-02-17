require "rails_helper"

RSpec.describe Api::CompaniesController, type: :request do
  let(:headers) do
    {
      "HTTP_AUTHORIZATION": Rails.application.credentials.dig(:external_api_secret)
    }
  end

  describe "update_badges" do
    it "returns 401 if secret is not as expected" do
      post api_update_company_badges_path(id: "some-id"), headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    let(:params) do
      {
        company: {
          badge_external_uids: %w[badge_1 badge_2]
        }
      }
    end

    it "replaces current badge associations with new ones" do
      company = FactoryBot.create(:company)
      badge1 = FactoryBot.create(:badge, external_uid: "badge_1")
      badge2 = FactoryBot.create(:badge, external_uid: "badge_2")
      badge3 = FactoryBot.create(:badge, external_uid: "badge_3")
      company.badges << badge3

      post api_update_company_badges_path(id: company.id), params: params, headers: headers
      expect(response.status).to eq 204

      company.reload
      expect(company.badges).to match_array [badge1, badge2]
    end

    it "reports error if company is missing" do
      post api_update_company_badges_path(id: "some-id"), params: params, headers: headers
      expect(response.status).to eq 404
    end

    it "ignores missing badges" do
      company = FactoryBot.create(:company)
      badge1 = FactoryBot.create(:badge, external_uid: "badge_1")

      post api_update_company_badges_path(id: company.id), params: params, headers: headers

      expect(response.status).to eq 204
      company.reload
      expect(company.badges).to eq [badge1]
    end
  end

  describe "update_roles" do
    it "returns 401 if secret is not as expected" do
      post api_update_company_roles_path(id: "some-uid"), headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    let(:params) do
      {
        company: {
          role_external_uids: %w[role_1 role_2]
        }
      }
    end

    it "replaces current roles associations with new ones" do
      company = FactoryBot.create(:company)
      role1 = FactoryBot.create(:role, external_uid: "role_1")
      role2 = FactoryBot.create(:role, external_uid: "role_2")
      role3 = FactoryBot.create(:role, external_uid: "role_3")
      company.roles << role3

      post api_update_company_roles_path(id: company.id), params: params, headers: headers
      expect(response.status).to eq 204

      company.reload
      expect(company.roles).to match_array [role1, role2]
    end

    it "reports error if company is missing" do
      post api_update_company_roles_path(id: "some-uid"), params: params, headers: headers

      expect(response.status).to eq 404
    end

    it "ignores missing roles" do
      company = FactoryBot.create(:company)
      role1 = FactoryBot.create(:role, external_uid: "role_1")
      post api_update_company_roles_path(id: company.id), params: params, headers: headers
      expect(response.status).to eq 204

      company.reload
      expect(company.roles).to eq [role1]
    end
  end
end
