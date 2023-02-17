class TemporaryBanner < ApplicationRecord
  extend Mobility

  translates :headline, :cta, :link, :is_displayed
  validates :is_displayed_i18n, json_boolean: true

  after_save :ensure_only_one_displayed_banner_for_locale, if: :saved_change_to_is_displayed_i18n?

  def self.current
    TemporaryBanner.where("(\"temporary_banners\".\"is_displayed_i18n\" ->> ?)::boolean = TRUE", I18n.locale).first
  end

  private

  def ensure_only_one_displayed_banner_for_locale
    self.class.where.not(id: id).update(is_displayed: false) if is_displayed(fallback: false)
  end
end
