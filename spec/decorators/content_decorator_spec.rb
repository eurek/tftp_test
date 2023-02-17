require "rails_helper"

RSpec.describe ContentDecorator do
  describe "#meta_title_with_fallback" do
    it "return content's meta_title if present" do
      content = FactoryBot.build(:content)

      expect(content.decorate.meta_title_with_fallback).to eq(content.meta_title)
    end

    it "return content's title if meta_title is not present" do
      content = FactoryBot.build(:content, meta_title: nil)

      expect(content.decorate.meta_title_with_fallback).to eq(content.title)
    end
  end

  describe "#meta_description_with_fallback" do
    it "returns content's meta_description if present" do
      content = FactoryBot.build(:content)

      expect(content.decorate.meta_description_with_fallback).to eq(content.meta_description)
    end

    it "returns content's body first 160 characters if meta_description is not present" do
      content = FactoryBot.build(:content,
        meta_description: nil,
        body:
          "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et "\
          "dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex "\
          "ea commodo consequat.</p>")

      expect(content.decorate.meta_description_with_fallback).to eq(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et "\
        "dolore magna aliqua. Ut enim ad minim veniam, quis nostrud"
      )
    end

    it "returns nil when neither meta description nor body are present" do
      content = FactoryBot.build(:content, meta_description: nil, body: nil)

      expect(content.decorate.meta_description_with_fallback).to be nil
    end
  end

  describe "#call_to_action" do
    it "returns default call to action when content has none" do
      content = FactoryBot.create(:content, status: "published")
      default_call_to_action = FactoryBot.create(:call_to_action,
        id: Rails.application.credentials.dig(:default_cta_id))

      expect(content.decorate.call_to_action).to eq(default_call_to_action)
    end
  end
end
