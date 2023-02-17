require "rails_helper"

RSpec.describe Api::StatisticsController, type: :request do
  describe "update" do
    it "returns 401 if secret is not as expected" do
      post api_update_statistics_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    let(:headers) do
      {
        "HTTP_AUTHORIZATION": Rails.application.credentials.dig(:external_api_secret)
      }
    end

    let(:webhook_params) do
      {
        statistics: {
          date: "2021/04",
          total_shareholders: "19732",
          total_innovations_assessed: "118",
          total_innovations_assessors: "656"
        }
      }
    end

    let(:json_keys) do
      %w[id date total_shareholders total_innovations_assessed total_innovations_assessors]
    end

    it "creates a new statistc if it doesn't exist" do
      expect {
        post api_update_statistics_path, params: webhook_params, headers: headers
      }.to change {
        Statistic.count
      }.by 1

      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys

      statistic = Statistic.first
      webhook_params[:statistics].except(:date).each do |key, value|
        expect(statistic.send(key)).to eq(value.to_i)
      end

      expect(statistic.date).to eq Date.parse(webhook_params[:statistics][:date])
    end

    it "updates an existing statistic if it already exists" do
      statistic = FactoryBot.create(:statistic, date: Date.parse(webhook_params[:statistics][:date]))

      expect {
        post api_update_statistics_path, params: webhook_params, headers: headers
      }.not_to change {
        Statistic.count
      }

      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys

      statistic.reload
      webhook_params[:statistics].except(:date).each do |key, value|
        expect(statistic.send(key)).to eq(value.to_i)
      end

      expect(statistic.date).to eq Date.parse(webhook_params[:statistics][:date])
    end
  end
end
