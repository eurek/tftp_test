require "rails_helper"

describe "SharesPurchasesController" do
  describe "become_shareholder" do
    let!(:highlighted) { FactoryBot.create(:highlighted_content, reason_to_join_ids: []) }

    it "loads team_members in O(1)" do
      test_sql_predictability(
        -> {
          individual = FactoryBot.create(:individual, :with_picture, reasons_to_join: "Bla blou")
          highlighted.update(reason_to_join_ids: highlighted.reason_to_join_ids.push(individual.id))
        },
        -> { get become_shareholder_path(locale: :fr) }
      )
    end
  end
end
