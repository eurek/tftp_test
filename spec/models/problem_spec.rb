require "rails_helper"

describe Problem, type: :model do
  it {
    is_expected.to define_enum_for(:action_lever).with_values(
      zero_emission: "zero_emission",
      energetical_efficacy: "energetical_efficacy",
      sobriety: "sobriety",
      captation: "captation"
    ).backed_by_column_of_type(:string)
  }

  it {
    is_expected.to define_enum_for(:domain).with_values(
      energy: "energy",
      industry: "industry",
      transport: "transport",
      agriculture: "agriculture",
      building: "building"
    ).backed_by_column_of_type(:string)
  }

  it "should scope by position" do
    FactoryBot.create(:problem, position: 3)
    FactoryBot.create(:problem, position: 1)
    FactoryBot.create(:problem, position: 2)

    expect(Problem.by_position.pluck(:position)).to eq [1, 2, 3]
    expect(Problem.pluck(:position)).to eq [3, 1, 2]
  end
end
