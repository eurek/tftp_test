module TranslationSearch
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model

    ransacker :value do
      Arel.sql("translations.value_i18n::text")
    end
  end
end
