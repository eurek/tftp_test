class SponsorshipCampaignsController < ApplicationController
  layout "private_space"
  before_action :set_user
  skip_before_action :authenticate_user!, only: [:public_show]

  def dashboard
    @total_shareholders = StatisticsCollecter.new.shareholders_count[:all]
    @sponsorship_campaign_link = ambassador_landing_url(ambassador_slug: @user.individual.public_slug, locale: nil)
  end

  def public_show
    individual = Individual.find_by_slug(params[:id]) || Individual.joins(:user).find_by!("users.id": params[:id])

    fullpath = "#{root_path}?utm_medium=ambassador&ambassador=#{individual.to_param}"
    redirect_to fullpath, status: :moved_permanently
  end
end
