class EpisodesController < ApplicationController
  skip_before_action :authenticate_user!
  layout "static"

  def show
    @episode = Episode.find(params[:id]).decorate
    @episodes = Episode.past_and_current.ordered_by_season
    @total_raised = @episode.total_raised
    @current_episode = Episode.current
    unless @episode.current?
      @funded_innovations = @episode.funded_innovations
        .map { |funded_innovation| funded_innovation.innovation.decorate }
      @total_funded_innovations = @episode.total_funded_innovations
    end
  end
end
