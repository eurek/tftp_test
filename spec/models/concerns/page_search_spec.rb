require "rails_helper"

RSpec.describe PageSearch, type: :model do
  describe "ransacker :title" do
    it "allows searching by contents title in the current locale" do
      page = FactoryBot.create(:page, title_i18n: {"en" => "English", "fr" => "Français"})

      I18n.locale = :en
      expect(Page.ransack(title_cont: "English").result).to eq [page]
      expect(Page.ransack(title_cont: "Français").result).to eq []

      I18n.locale = :fr
      expect(Page.ransack(title_cont: "English").result).to eq []
      expect(Page.ransack(title_cont: "Français").result).to eq [page]
    end
  end

  describe "ransacker :body" do
    it "allows searching by contents title in the current locale" do
      page = FactoryBot.create(:page, body_i18n: {"en" => "English", "fr" => "Français"})

      I18n.locale = :en
      expect(Page.ransack(body_cont: "English").result).to eq [page]
      expect(Page.ransack(body_cont: "Français").result).to eq []

      I18n.locale = :fr
      expect(Page.ransack(body_cont: "English").result).to eq []
      expect(Page.ransack(body_cont: "Français").result).to eq [page]
    end
  end
end
