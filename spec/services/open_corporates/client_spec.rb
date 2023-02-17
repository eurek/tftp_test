require "rails_helper"

describe OpenCorporates::Client do
  before(:all) do
    @api_url = OpenCorporates::Client.base_uri
    @api_search_url = @api_url + "/companies/search"
    @api_fetch_url = @api_url + "/companies/fr/512855594"
    @search_body = File.open(Rails.root.join("spec/mocks/open_corporates/search_mock.json")).read
    @company_body = File.open(Rails.root.join("spec/mocks/open_corporates/fetch_mock.json")).read
  end

  describe "search through companies" do
    it "sends an error in sentry if token is invalid" do
      allow(Sentry).to receive(:capture_message).and_return("")
      stub_request(:get, /#{Regexp.quote(@api_search_url)}/).to_return({status: 401})
      OpenCorporates::Client.new.search("France Television")

      expect(Sentry).to have_received(:capture_message)
    end

    it "parses results as companies" do
      stub_request(:get, /#{Regexp.quote(@api_search_url)}/).to_return({status: 200, body: @search_body})
      results = OpenCorporates::Client.new.search("France Television")
      expect(results.count).to eq 20

      company = results.first
      expect(company.id).to eq nil
      expect(company.name).to eq "France Television Publicite Conseil"
      expect(company.open_corporates_company_number).to eq "382258622"
      expect(company.open_corporates_jurisdiction_code).to eq "fr"
      expect(company.address).to eq "64 A 70 64 Avenue J B Clement\n92100 Boulogne Billancourt, Hauts De Seine, France"
      expect(company.street_address).to eq "64 A 70 64 Avenue J B Clement"
      expect(company.zip_code).to eq "92100"
      expect(company.city).to eq "Boulogne-Billancourt"
      expect(company.country).to eq "FRA"
      expect(company.website).to eq nil
      expect(company.is_displayed).to eq false
    end

    it "can handle API errors" do
      stub_request(:get, /#{Regexp.quote(@api_search_url)}/).to_return({status: 400, body: "{}"})
      results = OpenCorporates::Client.new.search("France Television")
      expect(results).to eq []
    end
  end

  describe "accessing a company's details" do
    it "sends an error in sentry if token is invalid" do
      allow(Sentry).to receive(:capture_message).and_return("")
      stub_request(:get, /#{Regexp.quote(@api_fetch_url)}/).to_return({status: 401})
      OpenCorporates::Client.new.get(:fr, "512855594")

      expect(Sentry).to have_received(:capture_message)
    end

    it "returns a company when found" do
      stub_request(:get, /#{Regexp.quote(@api_fetch_url)}/).to_return({status: 200, body: @company_body})
      company = OpenCorporates::Client.new.get(:fr, "512855594")

      expect(company.id).to eq nil
      expect(company.name).to eq "Aol"
      expect(company.open_corporates_company_number).to eq "512855594"
      expect(company.open_corporates_jurisdiction_code).to eq "fr"
      expect(company.address).to eq "49 Rue Voltaire\n92300 Levallois Perret, Hauts De Seine, France"
      expect(company.street_address).to eq "49 Rue Voltaire"
      expect(company.zip_code).to eq "92300"
      expect(company.city).to eq "Levallois-Perret"
      expect(company.country).to eq "FRA"
      expect(company.website).to eq "http://www.example.com/"
      expect(company.is_displayed).to eq false
    end

    it "returns nil if not found" do
      stub_request(:get, /#{Regexp.quote(@api_fetch_url)}/).to_return({status: 404, body: "{}"})
      company = OpenCorporates::Client.new.get(:fr, "512855594")
      expect(company).to eq nil
    end
  end
end
