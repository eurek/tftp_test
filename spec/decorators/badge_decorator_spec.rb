require "rails_helper"

RSpec.describe BadgeDecorator do

  describe "#picture_dark" do
    it "render url for picture dark when is attached" do
      badge_with_picture_dark = FactoryBot.create(:badge, :with_picture_dark)

      expect(badge_with_picture_dark.decorate.picture_dark).to eq(badge_with_picture_dark.picture_dark)
    end

    it "render fallback picture dark when no attachment" do
      badge = FactoryBot.create(:badge)

      expect(badge.decorate.picture_dark).to eq("default-badge-dark.png")
    end
  end

  describe "#picture_light" do
    it "render url for picture light when is attached" do
      badge_with_picture_light = FactoryBot.create(:badge, :with_picture_light)

      expect(badge_with_picture_light.decorate.picture_light).to eq(badge_with_picture_light.picture_light)
    end

    it "render fallback picture light when no attachment" do
      badge = FactoryBot.create(:badge)

      expect(badge.decorate.picture_light).to eq("default-badge-light.png")
    end
  end
end
