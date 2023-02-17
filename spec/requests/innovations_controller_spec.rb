require "rails_helper"

RSpec.describe InnovationsController, type: :request do
  describe "index" do
    it "redirects to index with submitted_to_evaluations filter if status filter equals received" do
      get innovations_path(locale: :fr, search: "cool", status: :received)

      expect(response.status).to eq 302
      expect(response).to redirect_to(innovations_path(locale: :fr, search: "cool", status: :submitted_to_evaluations))
    end
  end

  describe "funded show" do
    it "loads team_members in O(1)" do
      innovation = FactoryBot.create(:innovation, status: "star")
      FactoryBot.create(:funded_innovation, innovation: innovation)
      test_sql_predictability(
        -> { FactoryBot.create(:individual, :with_picture, funded_innovation_id: innovation.funded_innovation.id) },
        -> { get innovation_path(innovation, locale: :fr) }
      )
    end

    it "loads evaluators in O(1)" do
      innovation = FactoryBot.create(:innovation, status: "star")
      FactoryBot.create(:funded_innovation, innovation: innovation)
      test_sql_predictability(
        -> { innovation.evaluators << FactoryBot.create(:individual, :with_picture) },
        -> { get innovation_path(innovation, locale: :fr) }
      )
    end

    it "loads all evaluators in O(1)" do
      innovation = FactoryBot.create(:innovation, status: "star")
      FactoryBot.create(:funded_innovation, innovation: innovation)
      test_sql_predictability(
        -> { innovation.evaluators << FactoryBot.create(:individual, :with_picture) },
        -> { get innovation_path(innovation, locale: :fr, evaluators: :all) }
      )
    end
  end
end
