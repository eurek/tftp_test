require "rails_helper"

RSpec.describe CompanyMatching, type: :model do
  before(:each) do
    @input = {
      name: "Edith Piaf",
      street_address: "18, rue des Lapins",
      zip_code: "93017",
      city: "Mârcel",
      country: "France",
      registration_number: "Siret RCS de Chez Moi 891 274 294 00017",
      legal_form: "SARL",
      structure_size: "1 personne"
    }

    @open_corporates_url = "https://api.opencorporates.com/v0.4/companies/search"
    @open_corporates_many = File.open(Rails.root.join("spec/mocks/open_corporates/search_mock.json")).read
    @open_corporates_one = File.open(Rails.root.join("spec/mocks/open_corporates/search_single_result_mock.json")).read
    @open_corporates_uk = File.open(
      Rails.root.join("spec/mocks/open_corporates/search_uk_company_number_mock.json")
    ).read
    @open_corporates_none = {
      "api_version": "0.4",
      "results": {
        "companies": []
      }
    }.to_json
    stub_request(:get, /#{Regexp.quote(@open_corporates_url)}/).to_return(status: 200, body: @open_corporates_many)
  end

  it "cleans up its input data" do
    Company.match_or_create(@input)
    expect(@input[:address]).to eq "18, rue des Lapins\n93017 Mârcel"
  end

  it "can match via registration number, even mal formed" do
    existing_company = create(
      :company,
      name: "Ma Corp", address: "Chez moi",
      open_corporates_company_number: "891274294",
      open_corporates_jurisdiction_code: "fr"
    )
    company = Company.match_or_create(@input)

    # found the company
    expect(company.id).to eq existing_company.id

    # kept the existing attributes identical
    expect(company.name).to eq "Ma Corp"
    expect(company.address).to eq "Chez Moi"

    # updated the missing ones
    expect(company.street_address).to eq "18, Rue Des Lapins"
    expect(company.zip_code).to eq "93017"
    expect(company.city).to eq "Mârcel"
    expect(company.country).to eq "FRA"
    expect(company.legal_form).to eq "SARL"
    expect(company.structure_size).to eq "1 personne"
  end

  it "can match via registration number, even mal formed and not in France" do
    existing_company = FactoryBot.create(
      :company,
      name: "Fondation Thalie", address: "Quelque part en Belgique",
      open_corporates_company_number: "0505642588",
      open_corporates_jurisdiction_code: "be"
    )
    @input[:country] = "Belgique"
    @input[:registration_number] = "0505642588"
    @input[:zip_code] = "1050"
    @input[:city] = "Brussels"

    company = Company.match_or_create(@input)

    # found the company
    expect(company.id).to eq existing_company.id

    # kept the existing attributes identical
    expect(company.name).to eq "Fondation Thalie"
    expect(company.address).to eq "Quelque Part En Belgique"

    # updated the missing ones
    expect(company.street_address).to eq "18, Rue Des Lapins"
    expect(company.zip_code).to eq "1050"
    expect(company.city).to eq "Brussels"
    expect(company.country).to eq "BEL"
    expect(company.legal_form).to eq "SARL"
    expect(company.structure_size).to eq "1 personne"
  end

  it "can match via name and address, partial" do
    existing_company = create(
      :company,
      name: "Edith Piaf Corp",
      address: "18 RUE DES LAPINS\n93017 MARCEL"
    )
    company = Company.match_or_create(@input)

    # found the company
    expect(company.id).to eq existing_company.id

    # kept the existing attributes identical
    expect(company.name).to eq "Edith Piaf Corp"
    expect(company.address).to eq "18 Rue Des Lapins\n93017 Marcel"

    # updated the missing ones
    expect(company.street_address).to eq "18, Rue Des Lapins"
    expect(company.zip_code).to eq "93017"
    expect(company.city).to eq "Mârcel"
    expect(company.country).to eq "FRA"
    expect(company.legal_form).to eq "SARL"
    expect(company.structure_size).to eq "1 personne"
  end

  it "alerts sentry if there seems to be duplicate companies" do
    allow(Sentry).to receive(:capture_message).and_return("")
    existing_company = FactoryBot.create(
      :company,
      name: "Edith PIAF CORP",
      address: "18 RUE DES LAPINS\n93017 MARCEL"
    )
    FactoryBot.create(
      :company,
      name: "Edith PIAF CORP",
      address: "18 RUE DES LAPINS\n93017 MARCEL"
    )

    company = Company.match_or_create(@input)

    # found the company
    expect(company.id).to eq existing_company.id
    expect(Sentry).to have_received(:capture_message)
  end

  it "can't match via name and address, if name is too different" do
    existing_company = FactoryBot.create(
      :company,
      name: "Edith PIAF CORP",
      address: "18 RUE DES LAPINS\n93017 MARCEL"
    )
    @input[:name] = "Edith Piaf Corporation"
    company = Company.match_or_create(@input)

    # did not found the company
    expect(company.id).not_to eq existing_company.id

    expect(company.name).to eq "Edith Piaf Corporation"
  end

  it "can match via name and zip code" do
    existing_company = create(
      :company,
      name: "Edith PIAF CORP",
      address: "93017 MARCEL"
    )
    company = Company.match_or_create(@input)

    # found the company
    expect(company.id).to eq existing_company.id

    # kept the existing attributes identical
    expect(company.name).to eq "Edith PIAF CORP"
    expect(company.address).to eq "93017 Marcel"

    # updated the missing ones
    expect(company.street_address).to eq "18, Rue Des Lapins"
    expect(company.zip_code).to eq "93017"
    expect(company.city).to eq "Mârcel"
    expect(company.country).to eq "FRA"
    expect(company.legal_form).to eq "SARL"
    expect(company.structure_size).to eq "1 personne"
  end

  it "cannot match via name and zip code if name is too different" do
    existing_company = FactoryBot.create(
      :company,
      name: "Edith PIAF CORP",
      address: "93017 MARCEL"
    )
    @input[:name] = "Edith Piaf Corporation"
    company = Company.match_or_create(@input)

    expect(company.id).not_to eq existing_company.id

    # kept the existing attributes identical
    expect(company.name).to eq "Edith Piaf Corporation"
  end

  it "can create a new company, matching it to OpenCorporates" do
    stub_request(:get, /#{Regexp.quote(@open_corporates_url)}/).to_return(status: 200, body: @open_corporates_one)
    company = Company.match_or_create(@input)

    # created the company
    expect(company).not_to be_nil

    # uses the attributes from OpenCorporates
    expect(company.name).to eq "France Television Publicite Conseil"
    expect(company.address).to eq "64 A 70 64 Avenue J B Clement\n92100 Boulogne Billancourt, Hauts De Seine, France"
    expect(company.street_address).to eq "64 A 70 64 Avenue J B Clement"
    expect(company.zip_code).to eq "92100"
    expect(company.city).to eq "Boulogne-Billancourt"
    expect(company.country).to eq "FRA"
    expect(company.open_corporates_company_number).to eq "382258622"
    expect(company.open_corporates_jurisdiction_code).to eq "fr"

    # completes with the given attributes
    expect(company.legal_form).to eq "SARL"
    expect(company.structure_size).to eq "1 personne"
  end

  it "set user as company admin if admin is blank and user is present" do
    stub_request(:get, /#{Regexp.quote(@open_corporates_url)}/).to_return(status: 200, body: @open_corporates_one)
    user = FactoryBot.create(:user)
    Company.match_or_create(@input, user)

    # created the company
    expect(Company.count).to eq(1)
    expect(Company.last.admin).to eq(user)
  end

  # TODO: Voir comment mieux gérer les pays, par exemple dans l'import cette entrprise avec ce company number
  # ne matchait pas avec open corporate parce que le pays n'était pas trouvé par la lib et ne correspondait donc pas
  # avec ce qu'il y avait dans ce qu'envoyait open corporate
  it "can create a new company, matching it to OpenCorporates even if not in France" do
    stub_request(:get, /#{Regexp.quote(@open_corporates_url)}/).to_return(status: 200, body: @open_corporates_uk)
    @input[:registration_number] = "10716441"
    @input[:country] = "Royaume-Uni"
    @input = {
      name: "Edith Piaf",
      street_address: "18, rue des Lapins",
      zip_code: "HA4 9UU",
      city: "Ruislip",
      country: "United Kingdom",
      registration_number: "10716436",
      legal_form: "Limited",
      structure_size: "10 Salariés"
    }
    company = Company.match_or_create(@input)

    # found the company
    expect(company).not_to be_nil

    # uses the attributes from OpenCorporates
    expect(company.name).to eq "514 Media Ltd"
    expect(company.address).to eq "C/O Diverset Ltd Ferrari House\n258 Field End Road\nHa4 9 Uu Ruislip, United Kingdom"
    expect(company.street_address).to eq "C/O Diverset Ltd Ferrari House\n258 Field End Road"
    expect(company.zip_code).to eq "HA4 9UU"
    expect(company.city).to eq "Ruislip"
    expect(company.country).to eq "GBR"
    expect(company.open_corporates_company_number).to eq "10716436"
    expect(company.open_corporates_jurisdiction_code).to eq "gb"

    # completes with the given attributes
    expect(company.legal_form).to eq "Limited"
    expect(company.structure_size).to eq "10 Salariés"
  end

  it "can create a new company, skipping OpenCorporates because there are too many results" do
    company = Company.match_or_create(@input)

    # found the company
    expect(company).not_to be_nil

    # not matched in OpenCorporates
    expect(company.open_corporates_company_number).to eq nil
    expect(company.open_corporates_jurisdiction_code).to eq nil

    # uses the given attributes
    expect(company.name).to eq "Edith Piaf"
    expect(company.address).to eq "18, Rue Des Lapins\n93017 Mârcel"
    expect(company.street_address).to eq "18, Rue Des Lapins"
    expect(company.zip_code).to eq "93017"
    expect(company.city).to eq "Mârcel"
    expect(company.country).to eq "FRA"
    expect(company.legal_form).to eq "SARL"
    expect(company.structure_size).to eq "1 personne"
  end

  it "can create a new company, skipping OpenCorporates because there are no results" do
    stub_request(:get, /#{Regexp.quote(@open_corporates_url)}/).to_return(status: 200, body: @open_corporates_none)
    company = Company.match_or_create(@input)

    # found the company
    expect(company).not_to be_nil

    # not matched in OpenCorporates
    expect(company.open_corporates_company_number).to eq nil
    expect(company.open_corporates_jurisdiction_code).to eq nil

    # uses the given attributes
    expect(company.name).to eq "Edith Piaf"
    expect(company.address).to eq "18, Rue Des Lapins\n93017 Mârcel"
    expect(company.street_address).to eq "18, Rue Des Lapins"
    expect(company.zip_code).to eq "93017"
    expect(company.city).to eq "Mârcel"
    expect(company.country).to eq "FRA"
    expect(company.legal_form).to eq "SARL"
    expect(company.structure_size).to eq "1 personne"
  end
end
