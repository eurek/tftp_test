module TranslationScopes
  extend ActiveSupport::Concern

  included do
    # define fr and en scopes
    I18n.available_locales.each do |locale|
      scope locale, -> { where(locale: locale.to_s) }
    end
  end

  class_methods do
    # lists available pages, corresponding to first part of the key
    # or the first two parts for files containing keys for multiple pages
    def translated_pages
      Translation.distinct.pluck(Arel.sql("SPLIT_PART(key, '.', 1)")) +
        %w[shareholder sponsorship_campaign private_space].map do |key|
          Translation.where("key LIKE ?", "#{key}%").distinct.pluck(
            Arel.sql("CONCAT(SPLIT_PART(key, '.', 1), '.', SPLIT_PART(key, '.', 2))")
          )
        end.flatten
    end
  end
end
