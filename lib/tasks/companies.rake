namespace :companies do
  desc "Get new address attributes from open corporate api"
  task fetch_address: :environment do
    puts "stats --------------- start"
    puts "Entreprise avec company number et sans ville"
    puts Company.where.not(open_corporates_company_number: nil).where(city: nil).count
    not_updated = []
    Company.where.not(open_corporates_company_number: nil).where(city: nil).limit(500).find_each do |company|
      company_from_open_corporate = OpenCorporates::Client.new.get(
        company.open_corporates_jurisdiction_code,
        company.open_corporates_company_number
      )
      if company_from_open_corporate
        company.update(company_from_open_corporate.attributes.slice("country", "street_address", "zip_code", "city"))
      else
        sleep(1)
        not_updated.push(company.id)
      end
    end
    puts "stats --------------- end"
    puts Company.where.not(open_corporates_company_number: nil).where(city: nil).count
    puts not_updated
  end
end
