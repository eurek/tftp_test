module IndividualSearch
  extend ActiveSupport::Concern

  included do
    include PgSearch::Model

    pg_search_scope :full_text_search,
      against: [:public_search_text],
      ignoring: :accents,
      using: {
        tsearch: {
          prefix: true
        }
      }
  end
end
