require "rails_helper"

RSpec.describe JsonInclusionValidator, type: :model do
  before { I18n.locale = :fr }

  class JsonBooleanExample
    include ActiveModel::Validations
    attr_accessor :param_i18n
    def param
      param_i18n&.fetch(I18n.locale, nil)
    end
    validates :param_i18n, json_boolean: true
  end

  describe "validates that a value is true, false or nil" do
    let(:example) { JsonBooleanExample.new }

    it "handles nil attribute" do
      example.param_i18n = nil

      expect(example.valid?).to eq true
      expect(example.param_i18n).to eq({"fr" => false})
    end

    it "handles empty attribute" do
      example.param_i18n = {}

      expect(example.valid?).to eq true
      expect(example.param_i18n).to eq({"fr" => false})
    end

    it "handles missing variant" do
      example.param_i18n = {"en" => true}

      expect(example.valid?).to eq true
      expect(example.param_i18n).to eq({"fr" => false, "en" => true})
    end

    it "handles blank variant" do
      example.param_i18n = {"fr" => ""}

      expect(example.valid?).to eq true
      expect(example.param_i18n).to eq({"fr" => false})
    end

    it "handles present variant" do
      example.param_i18n = {"fr" => true}

      expect(example.valid?).to eq true
      expect(example.param_i18n).to eq({"fr" => true})

      example.param_i18n = {"fr" => false}

      expect(example.valid?).to eq true
      expect(example.param_i18n).to eq({"fr" => false})
    end
  end
end
