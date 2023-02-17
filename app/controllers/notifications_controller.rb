class NotificationsController < ApplicationController
  include SharesPurchaseGraphData

  skip_before_action :authenticate_user!
  layout "static"

  def index
    @current_situation = CurrentSituation.first
    @total_shareholders = StatisticsCollecter.new.shareholders_count[:all]
    @total_raised = SharesPurchase.total_raised
    @statistics = Rails.cache.fetch("live_statistics", expires_in: 10.minutes) { StatisticsCollecter.new.live }
    @notifications = Notification
      .preload(:subject)
      .order(created_at: :desc)
      .page(params[:page])
      .decorate
  end
end
