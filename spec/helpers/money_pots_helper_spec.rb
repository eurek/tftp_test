require "rails_helper"

describe SponsorshipCampaignsHelper do
  before(:each) do
    @url = "https://time-planet.com"
    @title = "Aidez Time à sauver notre planète"
  end

  describe "#linkedin_share_link" do
    it "should generate the correct url for sharing on linkedin" do
      expect(linkedin_share_link(@url, @title)).to eq(
        "https://www.linkedin.com/shareArticle?url=https://time-planet.com" \
        "&title=Aidez%20Time%20%C3%A0%20sauver%20notre%20plan%C3%A8te"
      )
    end
  end

  describe "#facebook_share_link" do
    it "should generate the correct url for sharing on linkedin" do
      expect(facebook_share_link(@url)).to eq("https://www.facebook.com/sharer.php?u=https://time-planet.com")
    end
  end

  describe "#twitter_share_link" do
    it "should generate the correct url for sharing on linkedin" do
      expect(twitter_share_link(@url, @title)).to eq(
        "https://twitter.com/intent/tweet?url=https://time-planet.com" \
        "&text=Aidez%20Time%20%C3%A0%20sauver%20notre%20plan%C3%A8te&via=timeforplanet"
      )
    end
  end
end
