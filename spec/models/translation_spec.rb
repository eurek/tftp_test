require "rails_helper"

describe Translation, type: :model do
  describe "validation" do
    subject { build(:translation) }

    it { is_expected.to validate_presence_of(:key) }
    it { is_expected.to validate_uniqueness_of(:key) }
  end

  describe "original_value" do
    it "can retrieve its value in the original yaml files" do
      translation = create(:translation, key: "common.language", value_i18n: {fr: "YO"})
      expect(translation.value_fr).to eq "YO"
      expect(translation.original_value(:fr)).to eq "français"
    end
  end

  describe "available_locales" do
    it "can determine stored locales" do
      Translation.destroy_all
      expect(Translation.available_locales).to eq []

      create(:translation, value_i18n: {fr: "value"})
      expect(Translation.available_locales).to eq ["fr"]

      create(:translation, value_i18n: {es: "value", it: "value"})
      expect(Translation.available_locales.sort).to eq ["fr", "es", "it"].sort
    end
  end

  describe "to_hash" do
    it "generates a hash from available translations" do
      Translation.destroy_all
      expect(Translation.to_hash).to eq({})

      # flat key
      create(:translation, key: "test", value_i18n: {fr: "value"})
      expected = {
        fr: {
          test: "value"
        }
      }
      expect(Translation.to_hash).to eq expected

      # nested key
      create(:translation, key: "common.actions.new", value_i18n: {en: "new", it: "nuovo", fr: "nouveau"})
      expected = {
        fr: {
          test: "value",
          common: {
            actions: {
              new: "nouveau"
            }
          }
        },
        it: {
          common: {
            actions: {
              new: "nuovo"
            }
          }
        },
        en: {
          common: {
            actions: {
              new: "new"
            }
          }
        }
      }
      expect(Translation.to_hash).to eq expected
    end
  end

  describe "edit_as_json?" do
    it "is true when the original value is an array" do
      expect(build(:translation, key: "common.language").edit_as_json?).to eq false
      expect(build(:translation, key: "common.test").edit_as_json?).to eq true
    end

    it "allows saving JSON data" do
      I18n.locale = :en
      t = Translation.create(key: "common.test", value: ["foo", "bar"])
      expect(t.edit_as_json?).to eq true

      # save the proper type
      t.value = ["foo", "bar", "baz"]
      expect(t).to be_valid
      t.save
      expect(t.reload.value).to eq ["foo", "bar", "baz"]

      # save as json
      t.value = '["foo", "bar", "baz"]'
      expect(t).to be_valid
      expect(t.value).to eq ["foo", "bar", "baz"]

      # invalid json: add error message, keep as is
      t.value = '["foo", "bar", "baz", ]'
      expect(t).not_to be_valid
      expect(t.errors[:value]).to eq [I18n.t("activerecord.errors.messages.invalid_json")]
      expect(t.value).to eq '["foo", "bar", "baz", ]'
    end
  end
end
