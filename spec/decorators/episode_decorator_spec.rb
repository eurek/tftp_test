require "rails_helper"

RSpec.describe EpisodeDecorator do
  describe "#display_code" do
    it "displays the season and episode numbers code" do
      episode = FactoryBot.create(:episode, season_number: 0, number: 22)

      expect(episode.decorate.display_code).to eq("S00E22")
    end
  end

  describe "#fundraising_goal" do
    it "returns the fundraising goal if present" do
      episode = FactoryBot.create(:episode, fundraising_goal: 8_000_000)

      expect(episode.decorate.fundraising_goal).to eq(8_000_000)
    end

    it "returns 1 billion if fundraising goal not present" do
      episode = FactoryBot.create(:episode)

      expect(episode.decorate.fundraising_goal).to eq(1_000_000_000)
    end
  end

  describe "#cover_image_with_fallback" do
    it "returns the cover image if present" do
      episode_with_cover_image = FactoryBot.create(:episode, :with_cover_image)

      expect(episode_with_cover_image.decorate.cover_image_with_fallback([1200, 1200]))
        .to eq(h.url_for(episode_with_cover_image.cover_image.variant(resize_to_limit: [1200, 1200])))
    end

    it "returns the fallback image if cover image is not present" do
      episode_without_cover_image = FactoryBot.create(:episode)

      expect(episode_without_cover_image.decorate.cover_image_with_fallback([1200, 1200]))
        .to eq("forest-with-sunrise.jpg")
    end
  end

  describe "#duration" do
    it "returns a sentence with the duration of the episode" do
      episode = FactoryBot.create(:episode, started_at: Date.new(2022, 9, 1), finished_at: Date.new(2022, 9, 20))

      expect(episode.decorate.duration).to eq("Du 01/09/2022 au 20/09/2022")
    end
  end

  describe "#time_status" do
    it "returns current if episode is current" do
      episode = FactoryBot.create(:episode, :current)

      expect(episode.decorate.time_status).to eq("En cours")
    end

    it "returns finished if episode is finished" do
      episode = FactoryBot.create(:episode, started_at: Date.today - 2.months, finished_at: Date.today - 1.months)

      expect(episode.decorate.time_status).to eq("Terminé")
    end

    it "returns coming if episode is coming" do
      episode = FactoryBot.create(:episode, started_at: Date.today + 1.months, finished_at: Date.today + 2.months)

      expect(episode.decorate.time_status).to eq("A venir")
    end
  end
end
