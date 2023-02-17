require "rails_helper"

RSpec.describe TranslationSearch, type: :model do
  describe "ransacker :value" do
    it "allows searching even when value is a json" do
      I18n.locale = :en
      value = [
        {
          "title": "Zéro émission",
          "text": "Développer des sources d’énergie et matériaux qui n’émettent pas de GES.",
          "cover_image": "problems/alternative-energy-building-clouds-energy-356036 1.png"
        }
      ]
      translation = Translation.create(key: "test", value: value)
      expect(Translation.ransack(value_cont: "matériaux").result).to eq [translation]
    end
  end
end
