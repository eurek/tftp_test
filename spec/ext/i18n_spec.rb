require "rails_helper"

describe "I18n" do
  describe "#localize" do
    it "returns nil if object is nil" do
      expect(I18n.l(nil)).to be nil
      expect(I18n.localize(nil)).to be nil
    end

    it "localizes date as expected" do
      expect(I18n.l(Date.parse("16/02/2015"), locale: :en)).to eq("2015-02-16")
      expect(I18n.localize(Date.parse("16/02/2015"), locale: :en)).to eq("2015-02-16")
      expect(I18n.l(Date.parse("16/02/2015"), locale: :fr)).to eq("16/02/2015")
      expect(I18n.localize(Date.parse("16/02/2015"), locale: :fr)).to eq("16/02/2015")
    end
  end
end
