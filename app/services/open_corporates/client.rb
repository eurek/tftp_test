# Allow to call the OpenCorporates API
module OpenCorporates
  class Client
    include HTTParty
    base_uri "https://api.opencorporates.com/v0.4/"

    def initialize
      # cf https://api.opencorporates.com/documentation/API-Reference
      @options = {
        format: :json,
        query: {}
      }
      token = Rails.application.credentials.dig(:token_open_corporate)
      @options[:query][:api_token] = token unless token.nil?
    end

    def search(term, exact: false)
      term = term.strip + "*" if exact

      @options[:query] = @options[:query].merge({
        q: term,
        fields: "name,previous_names,postal_codes,company_number",
        current_status: "Active|Actif",
        order: "score",
        per_page: 20,
        sparse: true
      })

      response = self.class.get("/companies/search", @options)
      send_401_to_sentry(response)
      return [] unless response.code == 200

      results = response.parsed_response.fetch("results", nil)&.fetch("companies", nil) || []
      results.map do |company_json|
        deserialize(company_json)
      end
    end

    def get(jurisdiction_code, company_number)
      response = self.class.get("/companies/#{jurisdiction_code}/#{company_number}", @options)
      send_401_to_sentry(response)
      return nil unless response.code == 200

      deserialize(response.parsed_response["results"])
    end

    private

    def deserialize(company_json)
      company_json = company_json["company"]
      return nil if company_json.blank?

      data = company_json.fetch("data", nil)&.fetch("most_recent", nil)&.map { |value| value.fetch("datum") } || []
      website_datum = data.find { |datum| datum["data_type"] == "Website" }

      address_json = company_json["registered_address"] || {}

      company = Company.new
      company.name = company_json["name"]&.titleize
      company.open_corporates_company_number = company_json["company_number"]
      company.open_corporates_jurisdiction_code = company_json["jurisdiction_code"]
      company.address = deserialize_address(company_json)
      company.street_address = address_json["street_address"]
      company.zip_code = address_json["postal_code"]
      company.city = address_json["locality"]
      company.country = address_json["country"]
      company.website = website_datum&.fetch("description", nil)
      company.is_displayed = false
      company.valid? # Normalise country, titleize, etc

      company
    end

    def deserialize_address(company_json)
      address_json = company_json["registered_address"]
      return company_json["registered_address_in_full"]&.titleize unless address_json.present?

      street = address_json.fetch("street_address", nil)
      zip_city = [address_json.fetch("postal_code", nil), address_json.fetch("locality", nil)].compact.join(" ")
      region = address_json.fetch("region", nil)
      country = address_json.fetch("country", nil)

      line1 = street
      line2 = [zip_city, region, country].compact.join(", ")

      [line1, line2].join("\n").titleize
    end

    def send_401_to_sentry(response)
      Sentry.capture_message "Open Corporate API token invalid" if response.code == 401
    end
  end
end
