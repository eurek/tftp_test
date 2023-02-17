class Translation < ApplicationRecord
  include TranslationScopes
  include TranslationSearch
  extend Mobility

  translates :value

  validates :key, presence: true, uniqueness: true

  before_validation :typecast_values
  after_commit :reload_translations

  def original_value(locale)
    return nil if key.nil?

    files_backend = I18n.backend.try(:backends)&.find { |b| b.is_a?(I18n::Backend::Simple) }
    return nil unless files_backend

    key_parts = [locale.to_sym] + key.split(".").map(&:to_sym)
    files_backend.translations.dig(*key_parts)
  end

  def edit_as_json?
    original = original_value(:fr) || original_value(:en)
    original.is_a?(Array)
  end

  def self.available_locales
    Translation.select("DISTINCT jsonb_object_keys(value_i18n) AS locale").to_a.map(&:locale)
  end

  def self.to_hash
    all.each.with_object({}) do |t, hash|
      locales = t.value_i18n.keys
      locales.each do |locale|
        keys = [locale.to_sym] + t.key.split(I18n::Backend::Flatten::FLATTEN_SEPARATOR).map(&:to_sym)
        keys.each.with_index.inject(hash) do |iterator, (key, index)|
          if index == keys.size - 1
            iterator[key] = t.value(locale: locale, fallback: false)
          else
            iterator[key] ||= {}
          end
          iterator[key]
        end
      end
    end
  end

  protected

  def reload_translations
    backend = I18n.backend
    backend = backend.backends.find { |b| b.is_a?(I18n::Backend::ActiveRecord) } if backend.is_a?(I18n::Backend::Chain)
    backend.reload!
  end

  def typecast_values
    return unless edit_as_json?

    value = self.value
    return unless value.is_a?(String)

    self.value = JSON.parse(value, symbolize_names: true)
  rescue JSON::ParserError
    errors.add(:value, I18n.t("activerecord.errors.messages.invalid_json"))
  end
end
