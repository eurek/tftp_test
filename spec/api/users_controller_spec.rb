require "rails_helper"

RSpec.describe Api::UsersController, type: :request do
  let(:headers) do
    {
      "HTTP_AUTHORIZATION": Rails.application.credentials.dig(:external_api_secret)
    }
  end

  describe "update_badges" do
    it "returns 401 if secret is not as expected" do
      post api_update_individual_badges_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    let!(:individual) { FactoryBot.create(:individual) }
    let(:params) do
      {
        individual: {
          email: individual.email,
          badge_external_uids: %w[badge_1 badge_2]
        }
      }
    end

    it "replaces current badge associations with new ones" do
      badge1 = FactoryBot.create(:badge, external_uid: "badge_1")
      badge2 = FactoryBot.create(:badge, external_uid: "badge_2")
      badge3 = FactoryBot.create(:badge, external_uid: "badge_3")
      individual.badges << badge3

      post api_update_individual_badges_path, params: params, headers: headers
      expect(response.status).to eq 204

      individual.reload
      expect(individual.badges).to eq [badge1, badge2]
    end

    it "reports error if individual is missing" do
      post api_update_individual_badges_path,
        params: params.merge({individual: {email: "wrong@email.com"}}),
        headers: headers

      expect(response.status).to eq 404
    end

    it "ignores missing badges" do
      badge1 = FactoryBot.create(:badge, external_uid: "badge_1")

      post api_update_individual_badges_path, params: params, headers: headers

      expect(response.status).to eq 204
      individual.reload
      expect(individual.badges).to eq [badge1]
    end
  end

  describe "update_roles" do
    it "returns 401 if secret is not as expected" do
      post api_update_individual_roles_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    let!(:individual) { FactoryBot.create(:individual) }
    let(:params) do
      {
        individual: {
          email: individual.email,
          role_external_uids: %w[role_1 role_2]
        }
      }
    end

    it "replaces current roles associations with new ones" do
      role1 = FactoryBot.create(:role, external_uid: "role_1")
      role2 = FactoryBot.create(:role, external_uid: "role_2")
      role3 = FactoryBot.create(:role, external_uid: "role_3")
      individual.roles << role3

      post api_update_individual_roles_path, params: params, headers: headers
      expect(response.status).to eq 204

      individual.reload
      expect(individual.roles).to match_array [role1, role2]
    end

    it "reports error if individual is missing" do
      post api_update_individual_roles_path,
        params: params.merge({individual: {email: "wrong@email.com"}}),
        headers: headers
      expect(response.status).to eq 404
    end

    it "ignores missing roles" do
      role1 = FactoryBot.create(:role, external_uid: "role_1")

      post api_update_individual_roles_path, params: params, headers: headers
      expect(response.status).to eq 204

      individual.reload
      expect(individual.roles).to eq [role1]
    end
  end

  describe "show" do
    it "returns 401 if secret is not as expected" do
      get api_user_path(external_uid: "uid"), headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    context "returns 200 if user is found by external_uid" do
      it "with only external_uid in response body if no additional fields is requested" do
        individual = FactoryBot.create(:individual, external_uid: "external-uid")

        get api_user_path(external_uid: individual.external_uid), headers: headers
        expect(response.status).to eq 200
        expect(response_json).to eq({"external_uid" => individual.external_uid})
      end

      it "with requested additional fields in response body" do
        individual = FactoryBot.create(:individual, external_uid: "external-uid")

        get api_user_path(external_uid: individual.external_uid, fields: ["is_displayed"]), headers: headers
        expect(response.status).to eq 200
        expect(response_json).to eq(
          {"external_uid" => individual.external_uid, "is_displayed" => individual.is_displayed}
        )
      end
    end

    it "returns 404 if individual is not found by external_uid" do
      FactoryBot.create(:individual, external_uid: "external-uid")

      get api_user_path(external_uid: "wrong-external-uid"), headers: headers
      expect(response.status).to eq 404
    end
  end

  describe "missing" do
    it "returns 401 if secret is not as expected" do
      post api_missing_users_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    it "returns 204 if all the external_uids are found in individuals table" do
      individual = FactoryBot.create(:individual, external_uid: "external-uid")
      FactoryBot.create(:individual, external_uid: "other-external-uid")

      post(
        api_missing_users_path,
        params: {external_uids: [individual.external_uid]},
        headers: headers
      )

      expect(response.status).to eq 200
    end

    it "returns 200 with external_uids not found in individuals table" do
      FactoryBot.create(:individual, external_uid: "1")
      FactoryBot.create(:individual, external_uid: "2")

      post(
        api_missing_users_path,
        params: {external_uids: ["1", "2", "3", "4"]},
        headers: headers
      )

      expect(response.status).to eq 200
      expect(response_json).to eq(["3", "4"])
    end

    it "returns 200 with all external_uids if none of the individuals are not found" do
      post(
        api_missing_users_path,
        params: {external_uids: ["1", "2"]},
        headers: headers
      )

      expect(response.status).to eq 200
      expect(response_json).to eq(["1", "2"])
    end
  end
end
