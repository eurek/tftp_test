require "rails_helper"

RSpec.describe FundedInnovation, type: :model do
  it { is_expected.to validate_presence_of(:funded_at) }
  it { is_expected.to validate_presence_of(:amount_invested) }
  it { is_expected.to belong_to(:innovation) }
  it {
    is_expected.to belong_to(:funding_episode).optional.class_name("Episode").with_foreign_key("funding_episode_id")
  }
  it { is_expected.to have_many(:team_members).class_name("Individual").with_foreign_key(:funded_innovation_id) }

  describe "associate_to_funding_episode callback" do
    it "should associate the innovation to the right episode based on submission date" do
      FactoryBot.create(
        :episode,
        number: 1,
        season_number: 1,
        started_at: Date.parse("01-01-2021"),
        finished_at: Date.parse("28-02-2021")
      )
      funding_episode = FactoryBot.create(
        :episode,
        number: 2,
        season_number: 1,
        started_at: Date.parse("01-03-2021"),
        finished_at: Date.parse("30-04-2021")
      )
      FactoryBot.create(
        :episode,
        number: 3,
        season_number: 1,
        started_at: Date.parse("01-05-2021"),
        finished_at: Date.parse("30-06-2021")
      )
      funded_innovation = FactoryBot.create(:funded_innovation, funded_at: Date.parse("24-03-2021"))

      expect(funded_innovation.reload.funding_episode).to eq(funding_episode)
    end
  end
end
