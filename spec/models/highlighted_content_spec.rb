require "rails_helper"

describe HighlightedContent, type: :model do
  describe "#remove_invalid_associate" do
    it "should remove nil element from array before save" do
      highlighted_content = FactoryBot.build(:highlighted_content)
      highlighted_content.associate_ids = [nil, "", 1, 2]

      highlighted_content.save

      expect(highlighted_content.reload.associate_ids).to eq([1, 2])
    end
  end
end
