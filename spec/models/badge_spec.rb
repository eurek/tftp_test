require "rails_helper"

RSpec.describe Badge, type: :model do
  describe "validations" do
    subject { FactoryBot.build(:badge) }
    it { is_expected.to have_many(:accomplishments).dependent(:destroy) }
    it { is_expected.to have_many(:individuals).through(:accomplishments) }
    it { is_expected.to have_many(:companies).through(:accomplishments) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:category) }
    it { is_expected.to validate_uniqueness_of(:external_uid) }
    it {
      is_expected.to define_enum_for(:category).with_values(
        year: "year",
        financial: "financial",
        action: "action",
        event: "event",
        honorific: "honorific",
        special: "special",
        role_actions: "role_actions",
        individual_sponsor: "individual_sponsor",
        help_comet: "help_comet",
        community_planet: "community_planet"
      ).with_suffix(:badge).backed_by_column_of_type(:string)
    }
  end

  describe "polymorphic relationship" do
    it "can have as many companies as users" do
      individual = FactoryBot.create(:individual)
      company = FactoryBot.create(:company)
      badge = FactoryBot.create(:badge)
      individual.badges << badge
      company.badges << badge

      company.reload
      individual.reload

      expect(company.badges.first).to eq(individual.badges.first)
      expect(badge.accomplishments.count).to eq(2)
      expect(individual.accomplishments.first.entity_id).to eq(individual.id)
      expect(company.accomplishments.last.entity_id).to eq(company.id)
      expect(badge.individuals).to eq([individual])
      expect(badge.companies).to eq([company])
    end
  end

  it "should be ordered by position by default" do
    badge2 = FactoryBot.create(:badge, position: 2)
    badge1 = FactoryBot.create(:badge, position: 1)
    individual = FactoryBot.create(:individual)
    individual.badges << [badge1, badge2]

    expect(Badge.all).to eq([badge1, badge2])
    expect(individual.badges).to eq([badge1, badge2])
  end
end
