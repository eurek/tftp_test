require "rails_helper"

RSpec.describe Role, type: :model do
  subject { FactoryBot.build(:role) }
  it { is_expected.to have_many(:role_attributions).dependent(:destroy) }
  it { is_expected.to have_many(:individuals).through(:role_attributions) }
  it { is_expected.to have_many(:companies).through(:role_attributions) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:external_uid) }
  it {
    is_expected.to define_enum_for(:attributable_to).with_values(
      user: "user",
      company: "company",
      all: "all"
    ).with_prefix(:attributable_to).backed_by_column_of_type(:string)
  }

  it "should be ordered by position by default" do
    role2 = FactoryBot.create(:role, position: 2)
    role1 = FactoryBot.create(:role, position: 1)
    individual = FactoryBot.create(:individual)
    individual.roles << [role1, role2]

    expect(Role.all).to eq([role1, role2])
    expect(individual.roles).to eq([role1, role2])
  end

  it "can have companies or individuals" do
    individual = FactoryBot.create(:individual)
    company = FactoryBot.create(:company)
    role = FactoryBot.create(:role)
    individual.roles << role
    company.roles << role

    company.reload
    individual.reload

    expect(company.roles.first).to eq(individual.roles.first)
    expect(role.role_attributions.count).to eq(2)
    expect(individual.role_attributions.first.entity_id).to eq(individual.id)
    expect(company.role_attributions.last.entity_id).to eq(company.id)
    expect(role.individuals).to eq([individual])
    expect(role.companies).to eq([company])
  end
end
