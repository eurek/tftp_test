require "rails_helper"

RSpec.describe Api::CurrentSituationsController, type: :request do
  describe "update_total_shareholders" do
    let!(:current_situation) { CurrentSituation.last }

    it "returns 401 if missing authentication" do
      post api_update_total_shareholders_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    it "updates the current situation" do
      headers = {"HTTP_AUTHORIZATION": Rails.application.credentials.dig(:external_api_secret)}
      params = {total_shareholders: 40}

      post api_update_total_shareholders_path, params: params, headers: headers
      expect(response.status).to eq 200

      current_situation.reload
      params.each do |key, value|
        expect(current_situation.send(key)).to eq(value)
      end
    end
  end
end
