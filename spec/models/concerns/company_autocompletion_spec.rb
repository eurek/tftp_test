require "rails_helper"

RSpec.describe CompanyAutocompletion, type: :model do
  before(:all) do
    @api_url = OpenCorporates::Client.base_uri
    @api_search_url = @api_url + "/companies/search"
    @search_body = File.open(Rails.root.join("spec/mocks/open_corporates/search_mock.json")).read
  end

  describe "autocomplete_suggestions" do
    describe "filters local companies" do
      before(:each) do
        stub_request(:get, /#{Regexp.quote(@api_search_url)}/).to_return({status: 200, body: "{}"})
        @france_tv_local = FactoryBot.create(:company, name: "France TV", address: "Paris")
        @aol_local = FactoryBot.create(:company, name: "AOL", address: "Paris")
      end

      it "with inexact match in name" do
        results = Company.autocomplete_suggestions("Franc")
        expect(results.count).to eq 1
        expect(results[0].id).to eq @france_tv_local.id
      end

      it "with inexact match in address" do
        results = Company.autocomplete_suggestions("Pâri")
        expect(results.count).to eq 2
        expect(results[0].id).to eq @france_tv_local.id
        expect(results[1].id).to eq @aol_local.id
      end

      it "with exact match in name" do
        results = Company.autocomplete_suggestions("FRANCE TV", true)
        expect(results.count).to eq 1
        expect(results[0].id).to eq @france_tv_local.id
      end

      it "with exact match in name without proper match" do
        results = Company.autocomplete_suggestions("FRANCE", true)
        expect(results.count).to eq 0
      end
    end

    describe "searches through OpenCorporates" do
      it "appends results after local DB results" do
        france_tv_local = FactoryBot.create(:company, name: "France TV", address: "Paris")
        FactoryBot.create(:company, name: "AOL", address: "Paris")

        stub_request(:get, /#{Regexp.quote(@api_search_url)}/).to_return({status: 200, body: @search_body})
        results = Company.autocomplete_suggestions("France")
        expect(results.count).to eq 21
        expect(results.map(&:id).count(&:present?)).to eq 1 # only 1 company in local DB
        expect(results[0].id).to eq france_tv_local.id
        expect(results[1].id).to eq nil
        expect(results[1].name).to eq "France Television Publicite Conseil"
      end

      it "excludes OpenCorporates companies that already exist in the DB" do
        france_tv_local = FactoryBot.create(
          :company,
          name: "France TV", address: "Paris",
          open_corporates_jurisdiction_code: "fr", open_corporates_company_number: "382258622"
        )
        FactoryBot.create(:company, name: "AOL", address: "Paris")

        stub_request(:get, /#{Regexp.quote(@api_search_url)}/).to_return({status: 200, body: @search_body})
        results = Company.autocomplete_suggestions("France")
        expect(results.count).to eq 20
        expect(results.map(&:id).count(&:present?)).to eq 1 # only 1 company in local DB
        expect(results[0].id).to eq france_tv_local.id
        expect(results[1].id).to eq nil
        expect(results[1].name).to eq "France Television Numerique"
      end
    end
  end
end
