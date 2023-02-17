require "rails_helper"

RSpec.describe InnovationDecorator do
  describe "#place" do
    it "displays city and country if both are present" do
      innovation = FactoryBot.create(:innovation, city: "Lyon", country: "FRA")

      expect(innovation.decorate.place).to eq("Lyon, France")
    end

    it "displays city if country is not present" do
      innovation = FactoryBot.create(:innovation, city: "Lyon")

      expect(innovation.decorate.place).to eq("Lyon")
    end

    it "displays country if city is not present" do
      innovation = FactoryBot.create(:innovation, country: "FRA")

      expect(innovation.decorate.place).to eq("France")
    end

    it "returns nil if neither city or country are present" do
      innovation = FactoryBot.create(:innovation)

      expect(innovation.decorate.place).to be nil
    end
  end
end
