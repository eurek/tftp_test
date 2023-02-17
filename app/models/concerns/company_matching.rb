module CompanyMatching
  extend ActiveSupport::Concern

  included do
    class << self
      def match_or_create(attributes, user = nil)
        # Prepare the data
        attributes[:address] ||= [
          *attributes[:street_address].presence,
          [
            *attributes[:zip_code].presence,
            *attributes[:city].presence
          ].join(" ")
        ].join("\n")

        # Case 1: Match by registration number
        company = Company.match_by_registration_number(attributes)

        # Case 2: Match by name and address
        if company.nil?
          # TODO: plus tard, quand les champs street_address etc seront aussi bien remplis que address, faire une
          # recherche sur [:street_address, :zip_code, :city] plutot que :address uniquement
          company = Company.match_by_name_and_address(attributes, :address)
        end

        # Case 3: Match by name and zip
        if company.nil?
          company = Company.match_by_name_and_address(attributes, :zip_code)
        end

        # Case 4: Create via open corporate
        if company.nil? && attributes[:registration_number]
          results = OpenCorporates::Client.new.search(attributes[:registration_number])
            .filter { |r| r.address.present? && r.country.present? }
            .filter { |r| r.country == ISO3166::Country.find_country_by_name(attributes[:country])&.alpha3 }

          if results.size == 1
            company = results[0]
          end
        end

        # Case 5: create simple
        if company.nil?
          company = Company.new(attributes.except(:registration_number))
        end

        # Now that we have a company: update its fields
        attributes.except(:registration_number).each do |key, value|
          company.assign_attributes(key => value) if company[key].blank?
        end
        if company.admin.blank? && user.present?
          company.admin = user
        end
        company.save
        company
      end

      def match_by_registration_number(attributes)
        registration_number = attributes[:registration_number] || ""
        registration_number = registration_number.delete(" ").delete("\u202F")
        return if registration_number.blank?

        siret_regex = /(?:\d\s*){9,14}/
        siret = siret_regex.match(registration_number).to_a.first

        if siret && attributes[:country] == "France"
          company = Company.find_by(
            open_corporates_company_number: siret[0...9],
            open_corporates_jurisdiction_code: "fr"
          )
          return company if company
        end

        country_code = ISO3166::Country.find_country_by_name(attributes[:country])&.alpha2&.downcase
        Company.find_by(
          open_corporates_company_number: attributes[:registration_number],
          open_corporates_jurisdiction_code: country_code
        )
      end

      TEXT_CLEANUP_RUBY = ->(text) {
        (text || "")
          .unaccent.downcase
          .delete(",")
          .delete("-")
          .delete("\r")
          .tr("\n", " ")
          .gsub("  ", " ")
      }.freeze

      TEXT_CLEANUP_SQL = ->(attr) {
        "unaccent(lower(#{attr}))"
          .gsub_sql(",", "")
          .gsub_sql("-", "")
          .gsub_sql("\r", "")
          .gsub_sql("\n", " ")
          .gsub_sql("  ", " ")
      }.freeze

      def match_by_name_and_address(attributes, address_field = :address)
        return nil if attributes[:name].blank? || attributes[address_field].blank?

        name = TEXT_CLEANUP_RUBY.call(attributes[:name])
        address = TEXT_CLEANUP_RUBY.call(attributes[address_field])

        companies = Company
          .where("#{TEXT_CLEANUP_SQL.call("name")} LIKE ?", "%#{name}%")
          .where("#{TEXT_CLEANUP_SQL.call("address")} LIKE ?", "%#{address}%")

        if companies.size > 1
          Sentry.capture_message "Duplicate companies", extra: {
            name: name,
            address: address,
            company_ids: companies.map(&:id)
          }
        end

        companies.first
      end
    end
  end
end
