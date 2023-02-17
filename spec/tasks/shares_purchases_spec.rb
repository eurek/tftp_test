require "rails_helper"

describe "Associate shares purchase with company" do
  after(:each) do
    Rake::Task["shares_purchases:associate_company"].reenable
  end

  it "if user only has one company and one shares purchase by company" do
    user = FactoryBot.create(:user)
    company = FactoryBot.create(:company, admin: user)
    shares_purchase = FactoryBot.create(:shares_purchase, company_info: {name: "Company 1"},
      individual: user.individual)

    Rake::Task["shares_purchases:associate_company"].invoke

    expect(shares_purchase.reload.company).to eq(company)
  end

  it "not if share purchase does not have a temporary_company_name" do
    user = FactoryBot.create(:user)
    FactoryBot.create(:company, admin: user)
    shares_purchase = FactoryBot.create(:shares_purchase, individual: user.individual)

    Rake::Task["shares_purchases:associate_company"].invoke

    expect(shares_purchase.reload.company).to be nil
  end

  it "not if user has several shares purchases made by company" do
    user = FactoryBot.create(:user)
    FactoryBot.create(:company, admin: user)
    shares_purchase_1 = FactoryBot.create(:shares_purchase, company_info: {name: "Company 3"},
      individual: user.individual)
    shares_purchase_2 = FactoryBot.create(:shares_purchase, company_info: {name: "Company 4"},
      individual: user.individual)

    Rake::Task["shares_purchases:associate_company"].invoke

    expect(shares_purchase_1.reload.company).to be nil
    expect(shares_purchase_2.reload.company).to be nil
  end

  it "not if user has several companies" do
    user = FactoryBot.create(:user)
    FactoryBot.create(:company, admin: user)
    FactoryBot.create(:company, admin: user)
    shares_purchase = FactoryBot.create(:shares_purchase, company_info: {name: "Company 3"},
      individual: user.individual)

    Rake::Task["shares_purchases:associate_company"].invoke

    expect(shares_purchase.reload.company).to be nil
  end
end
