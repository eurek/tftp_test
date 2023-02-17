module CompanyAutocompletion
  extend ActiveSupport::Concern

  included do
    class << self
      def autocomplete_suggestions(term, exact = false)
        local_companies = if exact
          Company.exact_name_search(term)
        else
          Company.full_text_search(term)
        end

        local_companies = local_companies.includes(:employees).limit(10)
        opencorporates_companies = OpenCorporates::Client.new.search(term, exact: exact)
        opencorporates_companies = filter_existing_companies(opencorporates_companies)

        local_companies + opencorporates_companies
      end

      private

      def filter_existing_companies(opencorporates_companies)
        return [] if opencorporates_companies.empty?

        fetched_ids = opencorporates_companies.map(&:open_corporates_full_id)

        concat = Arel::Nodes::NamedFunction.new(
          "concat",
          [arel_table[:open_corporates_jurisdiction_code], arel_table[:open_corporates_company_number]]
        )
        duplicate_ids = Company.where(concat.in(fetched_ids)).map(&:open_corporates_full_id)
        opencorporates_companies.reject { |company| duplicate_ids.include?(company.open_corporates_full_id) }
      end
    end

    def open_corporates_full_id
      [*open_corporates_jurisdiction_code, *open_corporates_company_number].join
    end
  end
end
