require "rails_helper"

RSpec.describe CompanyDecorator do
  describe "#completion_rate" do
    let(:company) do
      create(:company, address: "My address",
        description: " A nice description",
        co2_emissions_reduction_actions: "Actions to reduce co2 emissions",
        website: "ww.my-company.org",
        facebook: "www.facebook.com/my_company",
        linkedin: "www.linkedin.com/my_company")
    end

    it "returns 0.7 if all fields are completed except picture" do
      expect(company.decorate.completion_rate).to eq 0.7
    end

    it "returns 1 if all fields are completed" do
      company.logo.attach(
        io: File.open(Rails.root.join("spec/support/assets/picture-profile.jpg")),
        filename: "profile.jpg"
      )

      expect(company.decorate.completion_rate).to eq 1
    end
  end

end
