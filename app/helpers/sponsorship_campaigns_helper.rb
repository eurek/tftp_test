module SponsorshipCampaignsHelper
  def linkedin_share_link(url, title)
    "https://www.linkedin.com/shareArticle?url=#{url}&title=#{ERB::Util.url_encode(title)}"
  end

  def facebook_share_link(url)
    "https://www.facebook.com/sharer.php?u=#{url}"
  end

  def twitter_share_link(url, title)
    "https://twitter.com/intent/tweet?url=#{url}&text=#{ERB::Util.url_encode(title)}&via=timeforplanet"
  end
end
