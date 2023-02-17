require "rails_helper"

RSpec.describe ProblemsController, type: :request do
  describe "index" do
    it "loads data in O(1)" do
      test_sql_predictability(
        -> { FactoryBot.create(:problem, :with_cover) },
        -> { get problems_path({locale: :fr}) }
      )
    end
  end
end
