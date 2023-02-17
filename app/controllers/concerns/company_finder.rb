module CompanyFinder
  extend ActiveSupport::Concern

  included do
    def find_or_initialize_company(company_attributes)
      opencorporates_attributes = company_attributes.slice(
        :open_corporates_company_number,
        :open_corporates_jurisdiction_code
      )

      company = if company_attributes[:id].present?
        Company.find(company_attributes[:id])
      else
        Company.find_or_initialize_by(opencorporates_attributes) do |new_company|
          new_company.assign_attributes(company_attributes)
        end
      end
      company
    end

    def company_params
      params.require(:company).permit(
        :id,
        :name,
        :address,
        :open_corporates_company_number,
        :open_corporates_jurisdiction_code,
        :street_address,
        :zip_code,
        :city,
        :country
      )
    end
  end
end
