require "rails_helper"

RSpec.describe JsonPresenceValidator, type: :model do
  class Example
    include ActiveModel::Validations
    attr_accessor :param_i18n
    def param
      param_i18n&.fetch(I18n.locale, nil)
    end
    validates :param_i18n, json_presence: {attribute_name: :param}
  end

  describe "validates that an attribute contains a value for the current locale" do
    before(:each) do
      I18n.locale = :fr
    end

    it "handles nil attribute" do
      example = Example.new
      example.param_i18n = nil
      expect(example.valid?).to eq false
      expect(example.errors[:param]).to eq ["Merci d'indiquer Param"]
    end

    it "handles empty attribute" do
      example = Example.new
      example.param_i18n = {}
      expect(example.valid?).to eq false
      expect(example.errors[:param]).to eq ["Merci d'indiquer Param"]
    end

    it "handles missing variant for current locale" do
      example = Example.new
      example.param_i18n = {"en" => "Param"}
      expect(example.valid?).to eq false
      expect(example.errors[:param]).to eq ["Merci d'indiquer Param"]
    end

    it "handles blank variant for current locale" do
      example = Example.new
      example.param_i18n = {"fr" => ""}
      expect(example.valid?).to eq false
      expect(example.errors[:param]).to eq ["Merci d'indiquer Param"]
    end

    it "handles present variant for current locale" do
      example = Example.new
      example.param_i18n = {fr: "Param"}
      expect(example.valid?).to eq true

      example.param_i18n = {"fr" => "Param"}
      expect(example.valid?).to eq true
    end
  end
end
