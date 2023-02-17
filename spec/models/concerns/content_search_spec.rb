require "rails_helper"

RSpec.describe ContentSearch, type: :model do
  describe "ransacker :title" do
    it "allows searching by contents title in the current locale" do
      content = FactoryBot.create(:content, title_i18n: {"en" => "English", "fr" => "Français"})

      I18n.locale = :en
      expect(Content.ransack(title_cont: "English").result).to eq [content]
      expect(Content.ransack(title_cont: "Français").result).to eq []

      I18n.locale = :fr
      expect(Content.ransack(title_cont: "English").result).to eq []
      expect(Content.ransack(title_cont: "Français").result).to eq [content]
    end
  end

  describe "ransacker :body" do
    it "allows searching by contents title in the current locale" do
      content = FactoryBot.create(:content, body_i18n: {"en" => "English", "fr" => "Français"})

      I18n.locale = :en
      expect(Content.ransack(body_cont: "English").result).to eq [content]
      expect(Content.ransack(body_cont: "Français").result).to eq []

      I18n.locale = :fr
      expect(Content.ransack(body_cont: "English").result).to eq []
      expect(Content.ransack(body_cont: "Français").result).to eq [content]
    end
  end
end
