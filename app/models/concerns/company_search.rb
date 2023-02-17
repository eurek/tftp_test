module CompanySearch
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model

    scope :exact_name_search, lambda { |term|
      where("LOWER(UNACCENT(name)) = ?", I18n.transliterate(term&.downcase || ""))
    }

    pg_search_scope :name_search,
      against: :name,
      ignoring: :accents,
      using: {
        tsearch: {
          prefix: true
        }
      }

    pg_search_scope :full_text_search,
      against: [:name, :address],
      ignoring: :accents,
      using: {
        tsearch: {
          prefix: true
        }
      }
  end
end
