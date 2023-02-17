require "rails_helper"

RSpec.describe SharesPurchaseDecorator do
  describe "#buyer_display_name" do
    it "displays the temporary company name if there is no company id" do
      individual = FactoryBot.build(:individual, is_displayed: true)
      shares_purchase = FactoryBot.build(:shares_purchase, company_info: {name: "Company Inc"},
        individual: individual)

      expect(shares_purchase.decorate.buyer_display_name).to eq("Company Inc")
    end

    it "displays anonymous company if there is a temporary company name but the user is not displayed" do
      individual = FactoryBot.build(:individual, is_displayed: false)
      shares_purchase = FactoryBot.build(:shares_purchase, company_info: {name: "Company Inc"},
        individual: individual)

      expect(shares_purchase.decorate.buyer_display_name).to eq("Entreprise anonyme")
    end

    it "displays the company name if there is a company id" do
      company = FactoryBot.create(:company, name: "The Company Inc")
      shares_purchase = FactoryBot.create(:shares_purchase, company_info: {name: "Company Inc"}, company: company)

      expect(shares_purchase.decorate.buyer_display_name).to eq("The Company Inc")
    end

    it "displays anonymous company if the company isn't displayed" do
      company = FactoryBot.create(:company, name: "The Company Inc", is_displayed: false)
      shares_purchase = FactoryBot.create(:shares_purchase, company_info: {name: "Company Inc"}, company: company)

      expect(shares_purchase.decorate.buyer_display_name).to eq("Entreprise anonyme")
    end

    it "displays the user full name" do
      individual = FactoryBot.create(:individual, is_displayed: true)
      shares_purchase = FactoryBot.create(:shares_purchase, individual: individual)

      expect(shares_purchase.decorate.buyer_display_name).to eq("Jane Doe")
    end

    it "displays anonymous if the user is hidden" do
      individual = FactoryBot.create(:individual, is_displayed: false)
      shares_purchase = FactoryBot.create(:shares_purchase, individual: individual)

      expect(shares_purchase.decorate.buyer_display_name).to eq("Anonyme")
    end
  end

  describe "#type" do
    it "returns correct type value and css class if the shares purchase in made by a company" do
      shares_purchase = FactoryBot.build(:shares_purchase, company_info: {name: "Company Inc"})

      expect(shares_purchase.decorate.type).to eq({
        value: "Professionnel",
        css_class: "purple"
      })
    end

    it "returns correct type value and css class if the shares purchase in made by an individual" do
      shares_purchase = FactoryBot.build(:shares_purchase)

      expect(shares_purchase.decorate.type).to eq({
        value: "Citoyen",
        css_class: "lagoon"
      })
    end
  end
end
