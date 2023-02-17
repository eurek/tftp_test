require "rails_helper"

RSpec.describe ShareholdersConcern, type: :model do
  describe "shareholder_since" do
    context "for companies" do
      it "returns date of first completed shares purchase if present" do
        shares_purchase = FactoryBot.create(:shares_purchase, :from_company, status: "completed",
          completed_at: 3.days.ago)
        FactoryBot.create(:shares_purchase, company: shares_purchase.company, status: "completed",
          completed_at: 2.days.ago)

        expect(shares_purchase.company.reload.shareholder_since.change(usec: 0)).to eq(
          shares_purchase.completed_at.change(usec: 0)
        )
      end

      it "returns created at if no completed shares purchases are present" do
        company = FactoryBot.create(:company)
        FactoryBot.create(:shares_purchase, company: company, status: "canceled")

        expect(company.reload.shareholder_since).to eq(company.created_at)
      end
    end

    context "for individuals" do
      it "returns date of first shares purchase if present" do
        shares_purchase = FactoryBot.create(:shares_purchase, status: "completed", completed_at: 3.days.ago)
        FactoryBot.create(:shares_purchase, individual: shares_purchase.individual, status: "completed",
          completed_at: 2.days.ago)

        expect(shares_purchase.individual.reload.shareholder_since.change(usec: 0)).to eq(
          shares_purchase.completed_at.change(usec: 0)
        )
      end

      it "returns created at if no completed shares purchases are present" do
        individual = FactoryBot.create(:individual)
        FactoryBot.create(:shares_purchase, individual: individual, status: "canceled")

        expect(individual.reload.shareholder_since).to eq(individual.created_at)
      end
    end
  end

  describe "shares_total" do
    context "for companies" do
      let(:company) { FactoryBot.create(:company) }
      it "returns 0 if user has not bought any shares" do
        expect(company.shares_total).to eq(0)
      end

      it "returns the amount of the completed shares purchase if there is only one" do
        FactoryBot.create(:shares_purchase, :from_company, company: company, amount: 200, status: "completed")
        FactoryBot.create(:shares_purchase, :from_company, company: company, amount: 100, status: "canceled")

        expect(company.shares_total).to eq(200)
      end

      it "returns the sum of completed shares purchase if there are more than one" do
        FactoryBot.create(:shares_purchase, :from_company, company: company, amount: 100, status: "canceled")
        FactoryBot.create(:shares_purchase, :from_company, company: company, amount: 200, status: "completed")
        FactoryBot.create(:shares_purchase, :from_company, company: company, amount: 300, status: "completed")

        expect(company.shares_total).to eq(500)
      end
    end

    context "for individuals" do
      let(:individual) { FactoryBot.create(:individual) }
      it "returns 0 if user has not bought any shares" do
        expect(individual.shares_total).to eq(0)
      end

      it "returns the amount of the completed shares purchase if there is only one" do
        FactoryBot.create(:shares_purchase, individual: individual, amount: 200, status: "completed")
        FactoryBot.create(:shares_purchase, individual: individual, amount: 200, status: "canceled")

        expect(individual.shares_total).to eq(200)
      end

      it "returns the sum of completed shares purchase if there are more than one" do
        FactoryBot.create(:shares_purchase, individual: individual, amount: 200, status: "completed")
        FactoryBot.create(:shares_purchase, individual: individual, amount: 300, status: "completed")
        FactoryBot.create(:shares_purchase, individual: individual, amount: 100, status: "canceled")

        expect(individual.shares_total).to eq(500)
      end
    end
  end
end
