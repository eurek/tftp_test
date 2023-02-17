require "rails_helper"

RSpec.describe Accomplishment, type: :model do
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:entity_type).of_type(:string) }
  it { is_expected.to belong_to(:badge) }
  it { is_expected.to belong_to(:entity) }
  it { is_expected.to validate_inclusion_of(:entity_type).in_array(["Company", "Individual"]) }

  describe "polymorphic relationship" do
    it "can belongs to individual" do
      individual = FactoryBot.create(:individual, id: 666)
      company = FactoryBot.create(:company, id: 666)
      badge = FactoryBot.create(:badge)
      accomplishment = FactoryBot.create(:accomplishment, badge: badge, entity: individual)

      expect(accomplishment.entity_id).to eq(individual.id)
      expect(accomplishment.entity_type).to eq("Individual")
      expect(accomplishment.badge).to eq(badge)
      expect(individual.badges).to eq([badge])
      expect(company.badges).to eq([])
    end

    it "can belongs to company" do
      individual = FactoryBot.create(:individual, id: 666)
      company = FactoryBot.create(:company, id: 666)
      badge = FactoryBot.create(:badge)
      accomplishment = FactoryBot.create(:accomplishment_for_company, badge: badge, entity: company)

      expect(accomplishment.entity_id).to eq(company.id)
      expect(accomplishment.entity_type).to eq("Company")
      expect(company.badges).to eq([badge])
      expect(individual.badges).to eq([])
    end
  end
end
