require "rails_helper"

RSpec.describe IndividualSearch, type: :model do
  describe "full_text_search" do
    context "displayed" do
      before(:each) do
        @individual = FactoryBot.create(:individual, first_name: "Edith", last_name: "Piaf", is_displayed: true)
      end

      it "can search users by first name and last name" do
        expect(Individual.full_text_search("Edith")).to eq [@individual]
        expect(Individual.full_text_search("Piaf")).to eq [@individual]
        expect(Individual.full_text_search("Roger")).to eq []
      end

      it "ignores accents and casing" do
        expect(Individual.full_text_search("piâf")).to eq [@individual]
      end

      it "can search with partial search" do
        expect(Individual.full_text_search("Pi")).to eq [@individual]
      end
    end

    context "not displayed" do
      before(:each) do
        @individual = FactoryBot.create(:individual, first_name: "Edith", last_name: "Piaf", is_displayed: false)
      end

      it "cannot find the individual" do
        expect(Individual.full_text_search("Edith")).to eq []
        expect(Individual.full_text_search("Piaf")).to eq []
      end
    end
  end
end
