require "rails_helper"

describe "Float" do
  describe "#round_to_half" do
    it "rounds to closer half" do
      expect(1.24.round_to_half).to eq(1.0)
      expect(1.25.round_to_half).to eq(1.5)
      expect(1.74.round_to_half).to eq(1.5)
      expect(1.75.round_to_half).to eq(2)
    end
  end
end
