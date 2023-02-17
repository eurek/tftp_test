module CountryConcern
  extend ActiveSupport::Concern

  included do
    def valid_country_code
      return if country.nil?

      country = ISO3166::Country.find_country_by_alpha3(self.country)
      errors.add(:country, :invalid) if country.nil?
    end

    def normalize_country
      return if country.nil?

      country = ISO3166::Country[self.country] ||
        ISO3166::Country.find_country_by_alpha3(self.country) ||
        ISO3166::Country.find_country_by_alpha2(self.country) ||
        ISO3166::Country.find_country_by_name(self.country)
      self.country = country&.alpha3
    end
  end
end
