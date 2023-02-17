require "rails_helper"

RSpec.describe Api::TranslationsController, type: :request do
  describe "get" do
    it "responds with a string if translation key points to a string" do
      get api_translations_path, params: {translation_key: "common.choices_hint", locale: "fr"}

      expect(response.status).to eq 200
      expect(response_json).to eq("Choisir")
    end

    it "responds with hash if translation key points to a hash of translations" do
      get api_translations_path, params: {translation_key: "common.become_shareholder_navbar", locale: "fr"}

      expect(response.status).to eq 200
      expect(response_json).to eq(I18n.t("common.become_shareholder_navbar").stringify_keys)
      expect(response_json).to be_a(Hash)
    end
  end
end
