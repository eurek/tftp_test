require "rails_helper"

RSpec.describe JsonInclusionValidator, type: :model do
  before { I18n.locale = :fr }

  describe "without default value" do
    class JsonInclusionExample
      include ActiveModel::Validations
      attr_accessor :param_i18n
      def param
        param_i18n&.fetch(I18n.locale, nil)
      end
      validates :param_i18n, json_inclusion: {in: %w[foo bar], attribute_name: :param}
    end

    describe "validates that a value is included in allowed values for the current locale" do
      let(:example) { JsonInclusionExample.new }

      it "handles nil attribute" do
        example.param_i18n = nil

        expect(example.valid?).to eq false
        expect(example.errors[:param]).to eq ["'' is not an authorized value: foo, bar"]
      end

      it "handles empty attribute" do
        example.param_i18n = {}

        expect(example.valid?).to eq false
        expect(example.errors[:param]).to eq ["'' is not an authorized value: foo, bar"]
      end

      it "handles missing variant" do
        example.param_i18n = {"en" => "Param"}

        expect(example.valid?).to eq false
        expect(example.errors[:param]).to eq ["'' is not an authorized value: foo, bar"]
      end

      it "handles blank variant" do
        example.param_i18n = {"fr" => ""}

        expect(example.valid?).to eq false
        expect(example.errors[:param]).to eq ["'' is not an authorized value: foo, bar"]
      end

      it "handles present variant" do
        example.param_i18n = {fr: "foo"}

        expect(example.valid?).to eq true

        example.param_i18n = {"fr" => "foo"}

        expect(example.valid?).to eq true
      end
    end
  end

  describe "with default value" do
    class ExampleWithDefault
      include ActiveModel::Validations
      attr_accessor :param_i18n
      def param
        param_i18n&.fetch(I18n.locale, nil)
      end
      validates :param_i18n, json_inclusion: {in: %w[foo bar], default: "foo", attribute_name: :param}
    end

    describe "validates that a value is included in allowed values for the current locale" do
      let(:example) { ExampleWithDefault.new }

      it "handles nil attribute" do
        example.param_i18n = nil

        expect(example.valid?).to eq true
        expect(example.param_i18n).to eq({"fr" => "foo"})
      end

      it "handles empty attribute" do
        example.param_i18n = {}

        expect(example.valid?).to eq true
        expect(example.param_i18n).to eq({"fr" => "foo"})
      end

      it "handles missing variant" do
        example.param_i18n = {"en" => "bar"}

        expect(example.valid?).to eq true
        expect(example.param_i18n).to eq({"en" => "bar", "fr" => "foo"})
      end

      it "handles blank variant" do
        example.param_i18n = {"fr" => ""}

        expect(example.valid?).to eq true
        expect(example.param_i18n).to eq({"fr" => "foo"})
      end

      it "handles present variant" do
        example.param_i18n = {fr: "foo"}

        expect(example.valid?).to eq true

        example.param_i18n = {"fr" => "foo"}

        expect(example.valid?).to eq true
      end
    end
  end
end
