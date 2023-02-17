require "rails_helper"

RSpec.describe EventsController, type: :request do
  describe "index" do
    it "loads data in O(1)" do
      test_sql_predictability(
        -> { FactoryBot.create(:event, :with_picture) },
        -> { get events_path({locale: :fr}) }
      )
    end
  end
end
