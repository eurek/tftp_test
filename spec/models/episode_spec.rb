require "rails_helper"

describe Episode, type: :model do
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:season_number) }
  it { is_expected.to validate_presence_of(:started_at) }
  it { is_expected.to validate_presence_of(:finished_at) }
  it { should validate_uniqueness_of(:number).scoped_to(:season_number) }
  it {
    is_expected.to have_many(:submitted_innovations).class_name("Innovation").with_foreign_key("submission_episode_id")
  }
  it { is_expected.to have_many(:funded_innovations).with_foreign_key("funding_episode_id") }

  describe "ordered_by_season scope" do
    it "orders by season then by episode number" do
      e01s02 = FactoryBot.create(:episode, number: 1, season_number: 2)
      e01s03 = FactoryBot.create(:episode, number: 1, season_number: 3)
      e02s03 = FactoryBot.create(:episode, number: 2, season_number: 3)
      e01s01 = FactoryBot.create(:episode, number: 1, season_number: 1)
      e02s01 = FactoryBot.create(:episode, number: 2, season_number: 1)

      expect(Episode.ordered_by_season)
        .to eq([e01s01.reload, e02s01.reload, e01s02.reload, e01s03.reload, e02s03.reload])
    end
  end

  describe "past_and_current scope" do
    it "selects only past and current episodes" do
      e01s01 = FactoryBot.create(
        :episode, number: 1, season_number: 1, started_at: Date.today - 2.months, finished_at: Date.today - 1.month
      )
      e02s01 = FactoryBot.create(
        :episode, number: 2, season_number: 1, started_at: Date.today - 1.months, finished_at: Date.today - 1.day
      )
      e03s01 = FactoryBot.create(
        :episode, number: 3, season_number: 1, started_at: Date.today, finished_at: Date.today + 2.month
      )
      FactoryBot.create(
        :episode, number: 4, season_number: 1, started_at: Date.today + 2.months, finished_at: Date.today + 4.month
      )

      expect(Episode.past_and_current)
        .to eq([e01s01.reload, e02s01.reload, e03s01.reload])
    end
  end

  describe "finished_at_after_started_at validation" do
    it "validates that finished_at is after started_at" do
      episode = FactoryBot.build(
        :episode, number: 1, season_number: 1, started_at: Date.today, finished_at: Date.yesterday
      )

      expect(episode).not_to be_valid
      expect(episode.errors[:finished_at]).to eq(["cannot be before the start date"])
    end
  end

  describe ".current" do
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }

    it "returns the current episode" do
      FactoryBot.create(
        :episode, number: 1, season_number: 1, started_at: Date.today - 2.months, finished_at: Date.today - 1.month
      )
      current_episode = FactoryBot.create(
        :episode, number: 2, season_number: 1, started_at: Date.today - 1.months, finished_at: Date.today + 1.month
      )
      FactoryBot.create(
        :episode, number: 3, season_number: 1, started_at: Date.today + 1.months, finished_at: Date.today + 2.month
      )

      expect(Episode.current).to eq(current_episode)
    end

    describe "#current?" do
      it "returns true if episode is the current episode" do
        current_episode = FactoryBot.create(
          :episode, number: 2, season_number: 1, started_at: Date.today - 1.months, finished_at: Date.today + 1.month
        )
        expect(current_episode.current?).to be true
      end

      it "returns false if episode is not the current episode" do
        past_episode = FactoryBot.create(
          :episode, number: 2, season_number: 1, started_at: Date.today - 2.months, finished_at: Date.today - 1.month
        )
        expect(past_episode.current?).to be false
      end
    end

    scenario "cache current_episode for a day" do
      allow(Rails).to receive(:cache).and_return(memory_store)
      cache.clear
      expect(cache.exist?("current_episode")).to be(false)

      Episode.current

      expect(cache.exist?("current_episode")).to be(true)

      # expires after a day
      Timecop.freeze(Time.now + 1.day) do
        expect(cache.exist?("current_episode")).to be(false)

        Episode.current

        expect(cache.exist?("current_episode")).to be(true)
      end
    end

    scenario "cache is unvalidated when any modification is made on a episode" do
      allow(Rails).to receive(:cache).and_return(memory_store)
      cache.clear
      FactoryBot.create(
        :episode, number: 2, season_number: 1, started_at: Date.today - 1.months, finished_at: Date.today + 1.month
      )
      Episode.current
      expect(cache.exist?("current_episode")).to be(true)

      Episode.last.update(number: 3)

      expect(cache.exist?("current_episode")).to be(false)
    end

    it "returns a new episode if no current episode is present" do
      expect(Episode.current.number).to eq(0)
      expect(Episode.current.season_number).to eq(0)
      expect(Episode.current).not_to be_persisted
    end

    it "sends an error to Sentry if no current episode is present" do
      allow(Sentry).to receive(:capture_message).and_return("")
      Episode.current

      expect(Sentry).to have_received(:capture_message)
    end
  end

  describe "#total_raised" do
    it "returns the total amount of shares bought from the beginning of fundraising to the end of the episode" do
      episode = FactoryBot.create(:episode, started_at: Date.new(2022, 9, 1), finished_at: Date.new(2022, 9, 20))
      FactoryBot.create(:shares_purchase, completed_at: Date.new(2022, 8, 31), amount: 10, status: "completed")
      FactoryBot.create(:shares_purchase, completed_at: Date.new(2022, 9, 1), amount: 20, status: "completed")
      FactoryBot.create(:shares_purchase, completed_at: Date.new(2022, 9, 15), amount: 100, status: "completed")
      FactoryBot.create(:shares_purchase, completed_at: Date.new(2022, 9, 20), amount: 1, status: "completed")
      FactoryBot.create(:shares_purchase, completed_at: Date.new(2022, 9, 21), amount: 1000, status: "completed")

      expect(episode.total_raised).to eq(131)
    end
  end

  describe "#total_funded_innovations" do
    it "returns the total number of innovations funded until end of episode" do
      episode = FactoryBot.create(:episode, started_at: Date.new(2022, 9, 1), finished_at: Date.new(2022, 9, 20))
      FactoryBot.create(:funded_innovation, funded_at: Date.new(2022, 8, 31))
      FactoryBot.create(:funded_innovation, funded_at: Date.new(2022, 9, 1))
      FactoryBot.create(:funded_innovation, funded_at: Date.new(2022, 9, 15))
      FactoryBot.create(:funded_innovation, funded_at: Date.new(2022, 9, 20))
      FactoryBot.create(:funded_innovation, funded_at: Date.new(2022, 9, 21))

      expect(episode.total_funded_innovations).to eq 4
    end
  end
end
