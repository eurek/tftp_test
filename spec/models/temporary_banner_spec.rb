require "rails_helper"

describe TemporaryBanner, type: :model do
  it "should hide all other banner for current locale if displaying one" do
    I18n.locale = :fr
    former_banner = FactoryBot.create(:temporary_banner, is_displayed: true)

    new_banner = FactoryBot.create(:temporary_banner, is_displayed: true)

    expect(new_banner.is_displayed(locale: :fr)).to be true
    expect(former_banner.reload.is_displayed(locale: :fr)).to be false
  end

  it "self.current should return activated banner for current locale" do
    FactoryBot.create(:temporary_banner, is_displayed: false)
    current_banner = FactoryBot.create(:temporary_banner, is_displayed: true)

    expect(TemporaryBanner.current).to eq(current_banner)
  end
end
